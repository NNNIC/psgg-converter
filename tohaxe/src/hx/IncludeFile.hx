package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class IncludeFile
{
    public static function readfile(g:psggconverterlib.Convert, matchstr:String, file:String, enc:String):String
    {
        if (system.Cs2Hx.IsNullOrEmpty(enc))
        {
            enc = "utf-8";
        }
        var filepath:String = system.io.Path.Combine_String_String(g.INCDIR, file);
        if (!system.io.File.Exists(filepath))
        {
            filepath = system.io.Path.Combine_String_String(g.XLSDIR, file);
            if (!system.io.File.Exists(filepath))
            {
                filepath = system.io.Path.Combine_String_String(g.GENDIR, file);
            }
        }
        var text:String = "";
        if (system.io.File.Exists(filepath))
        {
            try
            {
                text = psgg.HxFile.ReadAllText_String_Encoding(filepath, psgg.HxEncoding.GetEncoding_String(enc));
            }
            catch (e:system.SystemException)
            {
                text = "(error: can not read : " + system.Cs2Hx.NullCheck(e.Message);
            }
        }
        else
        {
            text = "(error: file not found : " + system.Cs2Hx.NullCheck(filepath) + ")";
        }
        return text;
    }
    public function new()
    {
    }
}
