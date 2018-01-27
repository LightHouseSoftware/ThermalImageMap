import dlib.image;

// Jet-palette file's path
enum string PALETTE_JET = `palettes/jet.csv`;

import std.algorithm;
import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;
import std.file;

Color4f[] getPalette(string filename)
{
    Color4f[] palette;

    Color4f extractField(string triplet)
    {
        Color4f color;
        auto content = triplet.split(";");

        color.r = parse!float(content[0]) / 255.0f;
        color.g = parse!float(content[1]) / 255.0f;
        color.b = parse!float(content[2]) / 255.0f;

        return color;
    }

    palette = (cast(string)(read(filename)))
                                        .splitLines
                                        .map!(a => extractField(a))
                                        .array;

    return palette;
}

auto selectColor(ref Color4f[] colors, Color4f color)
{
    auto colorDistance(Color4f a, Color4f b)
    {
        auto dx = ((a.r - b.r) ^^ 2) +  ((a.g - b.g) ^^ 2) +  ((a.b - b.b) ^^ 2);

        return sqrt(dx);
    }

    auto distance = float.max;
    auto currentColor = Color4f(1.0f, 1.0f, 1.0f);

    foreach (paletteColor; colors)
    {
        if (colorDistance(color, paletteColor) < distance)
        {
            distance = colorDistance(color, paletteColor);
            currentColor = paletteColor;
        }
    }

    return currentColor;
}

auto createThermocard(SuperImage superImage, ref Color4f[] palette)
{
    SuperImage newImage = image(superImage.width, superImage.height);

    foreach (x; 0..superImage.width)
    {
        foreach (y; 0..superImage.height)
        {
            newImage[x,y] = selectColor(palette, superImage[x,y]);
        }
    }

    return newImage;
}

void main()
{
	// source image
    auto img = load(`Lenna.png`);
    auto palette = getPalette(PALETTE_JET);

    // create a thermal-image and save to a file
    createThermocard(img, palette).savePNG("Lenna_Jet.png");
}
