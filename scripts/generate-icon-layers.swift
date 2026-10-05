import AppKit
import ImageIO
import UniformTypeIdentifiers

func stripMetadata(at path:URL) throws {
    let encoded=try Data(contentsOf:path)
    var sanitized=Data(encoded.prefix(8)),position=8
    let keep:Set<String>=["IHDR","PLTE","tRNS","IDAT","IEND","sRGB","iCCP","gAMA","cHRM","pHYs"]
    while position+12<=encoded.count {
        let length=(0..<4).reduce(0) { ($0<<8)|Int(encoded[position+$1]) }
        let end=position+12+length
        precondition(end<=encoded.count)
        let tag=String(data:encoded[(position+4)..<(position+8)],encoding:.ascii)!
        if keep.contains(tag) { sanitized.append(encoded[position..<end]) }
        position=end
    }
    try sanitized.write(to:path,options:.atomic)
}
// Reuse Buddy's canonical cat; retain the selected curled tail below it.
let root=URL(fileURLWithPath:CommandLine.arguments[1],isDirectory:true)
let input=root.appendingPathComponent("Resources/AppIcon-black-tail.png")
let output=root.appendingPathComponent("Resources/AppIcon.icon",isDirectory:true)
let assets=output.appendingPathComponent("Assets",isDirectory:true)
try stripMetadata(at:root.appendingPathComponent("Resources/CanonicalCat.png"))
let source=CGImageSourceCreateWithURL(input as CFURL,nil).flatMap { CGImageSourceCreateImageAtIndex($0,0,nil) }!
let width=source.width,height=source.height
precondition(width<=2048 && height<=2048)
var pixels=[UInt8](repeating:0,count:width*height*4)
pixels.withUnsafeMutableBytes { buffer in
    let context=CGContext(data:buffer.baseAddress,width:width,height:height,bitsPerComponent:8,bytesPerRow:width*4,
        space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.draw(source,in:CGRect(x:0,y:0,width:width,height:height))
}
var alpha=[UInt8](repeating:0,count:width*height)
for index in alpha.indices {
    let i=index*4
    let brightness=(Double(pixels[i])+Double(pixels[i+1])+Double(pixels[i+2]))/3
    alpha[index]=UInt8((min(1,max(0,(brightness-8)/247))*255).rounded())
}
var visited=[Bool](repeating:false,count:width*height)
var components=[[Int]]()
for start in alpha.indices where alpha[start]>0 && !visited[start] {
    var component=[start],cursor=0;visited[start]=true
    while cursor<component.count {
        let index=component[cursor];cursor+=1
        let x=index%width,y=index/width
        for neighbor in [x>0 ? index-1 : -1,x+1<width ? index+1 : -1,y>0 ? index-width : -1,y+1<height ? index+width : -1]
            where neighbor>=0 && alpha[neighbor]>0 && !visited[neighbor] {
            visited[neighbor]=true;component.append(neighbor)
        }
    }
    if component.count>width*height/200 { components.append(component) }
}
components.sort { $0.count>$1.count }
precondition(components.count==2,"The selected artwork must contain its cat and curled tail")
try FileManager.default.createDirectory(at:assets,withIntermediateDirectories:true)
let cat=CGImageSourceCreateWithURL(root.appendingPathComponent("Resources/CanonicalCat.png") as CFURL,nil).flatMap { CGImageSourceCreateImageAtIndex($0,0,nil) }!
precondition(cat.width==1024 && cat.height==1024)
var catPixels=[UInt8](repeating:0,count:1024*1024*4)
catPixels.withUnsafeMutableBytes { buffer in
    let context=CGContext(data:buffer.baseAddress,width:1024,height:1024,bitsPerComponent:8,bytesPerRow:4096,
        space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.draw(cat,in:CGRect(x:0,y:0,width:1024,height:1024))
}
var rendered=[CGImage]()
for (number,name) in ["01-Cat","02-Tail"].enumerated() {
    var layer=[UInt8](repeating:0,count:pixels.count)
    for index in components[number] { for channel in 0..<4 { layer[index*4+channel]=alpha[index] } }
    let image=layer.withUnsafeMutableBytes { buffer -> CGImage in
        CGContext(data:buffer.baseAddress,width:width,height:height,bitsPerComponent:8,bytesPerRow:width*4,
            space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!.makeImage()!
    }
    let context=CGContext(data:nil,width:1024,height:1024,bitsPerComponent:8,bytesPerRow:4096,
        space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.interpolationQuality = .high
    if number==0 { context.draw(cat,in:CGRect(x:0,y:0,width:1024,height:1024)) }
    else {
        // Buddy's wider cat meets the old tail. Shift only the tail to leave
        // at least fourteen pixels of breathing room in overlapping columns.
        var tailPixels=[UInt8](repeating:0,count:1024*1024*4)
        tailPixels.withUnsafeMutableBytes { buffer in
            let canvas=CGContext(data:buffer.baseAddress,width:1024,height:1024,bitsPerComponent:8,bytesPerRow:4096,
                space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
            canvas.interpolationQuality = .high;canvas.draw(image,in:CGRect(x:0,y:0,width:1024,height:1024))
        }
        var offset=0
        for x in 0..<1024 {
            let catBottom=(0..<1024).last(where:{catPixels[($0*1024+x)*4+3]>8})
            let tailTop=(0..<1024).first(where:{tailPixels[($0*1024+x)*4+3]>8})
            if let catBottom,let tailTop { offset=max(offset,catBottom+14-tailTop) }
        }
        precondition(offset<100)
        context.draw(image,in:CGRect(x:0,y:-offset,width:1024,height:1024))
        print("Curled tail spacing adjustment: \(offset)px")
    }
    let result=context.makeImage()!
    rendered.append(result)
    let destination=CGImageDestinationCreateWithURL(assets.appendingPathComponent(name+".png") as CFURL,UTType.png.identifier as CFString,1,nil)!
    CGImageDestinationAddImage(destination,result,nil)
    precondition(CGImageDestinationFinalize(destination))
    // Keep encoded pixels and color-space chunks; exclude optional metadata.
    try stripMetadata(at:assets.appendingPathComponent(name+".png"))
}
let mark=CGContext(data:nil,width:1024,height:1024,bitsPerComponent:8,bytesPerRow:4096,
    space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
for layer in rendered { mark.draw(layer,in:CGRect(x:0,y:0,width:1024,height:1024)) }
let markDestination=CGImageDestinationCreateWithURL(root.appendingPathComponent("Resources/PetMark.png") as CFURL,UTType.png.identifier as CFString,1,nil)!
CGImageDestinationAddImage(markDestination,mark.makeImage()!,nil)
precondition(CGImageDestinationFinalize(markDestination))
try stripMetadata(at:root.appendingPathComponent("Resources/PetMark.png"))
// Music's installed icon background uses this Display P3 red endpoint. Convert
// the reference color to the extended-sRGB notation used by Icon Composer.
let componentsP3:[CGFloat]=[0.917,0.176,0.230,1]
let musicRed=NSColor(colorSpace:.displayP3,components:componentsP3,count:4).usingColorSpace(.extendedSRGB)!
let red=String(format:"extended-srgb:%.5f,%.5f,%.5f,1.00000",musicRed.redComponent,musicRed.greenComponent,musicRed.blueComponent)
let black="extended-srgb:0.00000,0.00000,0.00000,1.00000"
let document:[String:Any]=[
    "fill-specializations":[["value":["automatic-gradient":red]],["appearance":"dark","value":["solid":black]]],
    "groups":[[
        "layers":["01-Cat","02-Tail"].map { name -> [String:Any] in
            ["image-name":name+".png","name":name,"fill-specializations":[["appearance":"dark","value":["solid":red]]]]
        },
        "shadow":["kind":"neutral","opacity":0.5],"translucency":["enabled":true,"value":0.5]
    ]],
    "supported-platforms":["squares":"shared","circles":["watchOS"]]
]
try JSONSerialization.data(withJSONObject:document,options:[.prettyPrinted,.sortedKeys]).write(to:output.appendingPathComponent("icon.json"),options:.atomic)
print("Created canonical Buddy cat and curled tail; Music red: \(red)")
