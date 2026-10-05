import AppKit
import SwiftUI
import ImageIO

// Use the canonical cat and tail for both the app icon and frameless marks.
enum PetStoreBrand {
    static let applicationIcon: NSImage? = {
        guard let url=Bundle.main.url(forResource:"AppIcon",withExtension:"icns") else { return nil }
        return NSImage(contentsOf:url)
    }()
    private static let sourceGlyph:CGImage? = {
        guard let url=Bundle.main.url(forResource:"PetMark",withExtension:"png"),
              let file=CGImageSourceCreateWithURL(url as CFURL,nil),let source=CGImageSourceCreateImageAtIndex(file,0,nil) else { return nil }
        return makeGlyph(source)
    }()
    private static let templates=NSCache<NSString,NSImage>()
    static var glyph:NSImage? { template(size:64,scale:2) }
    static func template(size:CGFloat,scale:CGFloat) -> NSImage? {
        guard let source=sourceGlyph else { return nil }
        let pixels=max(1,Int((size*max(1,scale)).rounded()))
        let key="\(pixels)-\(size)" as NSString
        if let cached=templates.object(forKey:key) { return cached }
        guard let context=CGContext(data:nil,width:pixels,height:pixels,bitsPerComponent:8,bytesPerRow:pixels*4,
            space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.interpolationQuality = .high;context.setShouldAntialias(true)
        let ratio=min(CGFloat(pixels)/CGFloat(source.width),CGFloat(pixels)/CGFloat(source.height))
        let width=CGFloat(source.width)*ratio,height=CGFloat(source.height)*ratio
        context.draw(source,in:CGRect(x:(CGFloat(pixels)-width)/2,y:(CGFloat(pixels)-height)/2,width:width,height:height))
        guard let output=context.makeImage() else { return nil }
        let image=NSImage(cgImage:output,size:NSSize(width:size,height:size));image.isTemplate=true
        templates.countLimit=24;templates.setObject(image,forKey:key)
        return image
    }
    private static func makeGlyph(_ source:CGImage) -> CGImage? {
        guard source.width > 0,source.height > 0,source.width <= 2048,source.height <= 2048 else { return nil }
        let width=source.width,height=source.height
        var pixels=[UInt8](repeating:0,count:width*height*4)
        let output=pixels.withUnsafeMutableBytes { buffer -> CGImage? in
            guard let context=CGContext(data:buffer.baseAddress,width:width,height:height,bitsPerComponent:8,
                bytesPerRow:width*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
            context.draw(source,in:CGRect(x:0,y:0,width:width,height:height))
            let bytes=buffer.bindMemory(to:UInt8.self)
            var minX=width,minY=height,maxX = -1,maxY = -1
            for y in 0..<height {
                for x in 0..<width {
                    let i=(y*width+x)*4
                    let alpha=bytes[i+3]
                    bytes[i]=alpha;bytes[i+1]=alpha;bytes[i+2]=alpha;bytes[i+3]=alpha
                    if alpha > 0 {
                        minX=min(minX,x);minY=min(minY,y);maxX=max(maxX,x);maxY=max(maxY,y)
                    }
                }
            }
            guard maxX >= minX,maxY >= minY else { return nil }
            return context.makeImage()?.cropping(to:CGRect(x:minX,y:minY,width:maxX-minX+1,height:maxY-minY+1))
        }
        return output
    }
}

struct PetStoreMark: View {
    let size:CGFloat
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    var body:some View {
        Group {
            if let icon=PetStoreBrand.template(size:size,scale:displayScale) {
                Image(nsImage:icon).renderingMode(.template).interpolation(.high).antialiased(true)
            } else { Image(systemName:"cat.fill").resizable().scaledToFit() }
        }.frame(width:size,height:size)
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            .accessibilityHidden(true)
    }
}
