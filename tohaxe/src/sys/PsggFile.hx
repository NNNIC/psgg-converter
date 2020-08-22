import haxe.macro.Expr.Binop;
import haxe.io.Bytes;
import sys.io.File;

class PsggFile {
    public function new() {}

    public static function HasBomUTF8(path:String) : Bool {
        var data = File.getBytes(path);
        if (data==null || data.length<3) {
            return false;
        }
        return (data.get(0) == 0xEF && data.get(1) == 0xBB && data.get(2) == 0xBF);
    }
    public static function ReadUTF8(path:String) :String {
        var data = File.getBytes(path);
        var s = data.getString(0,data.length);
        if (s!=null && s.length > 0) {
            if (s.charCodeAt(0) == 0xFEFF) {
                return s.substr(1);
            }
        }        
        return s;
    }
    public static function ReadASCII(path:String) :String {
        return ReadUTF8(path);
    }
    public static function WriteUTF8(path:String, buf:String, bom:Bool) {
        var bom = StringTools.htmlUnescape("&#xFEFF;");
        var ibuf = buf;
        if (ibuf!=null && ibuf.charCodeAt(0) != 0xFEFF) {
            ibuf = bom + ibuf;
        }
        var data = Bytes.ofString(ibuf);
        File.saveBytes(path,data);
    }

    public static function WriteASCII(path:String, buf:String) {
        WriteUTF8(path,buf,false);
    }
}