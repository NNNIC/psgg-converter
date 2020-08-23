package psgg;

class HxFile {
    public function new () { }


    public static function ReadAllText_String_Encoding(path:String, enc:system.text.Encoding ) : String { 
        if (HxEncoding.IsASCIIEncoding(enc)){
            return PsggFile.ReadASCII(path);
        }
        return PsggFile.ReadUTF8(path);
    }
    public static function WriteAllText_String_String_Encoding(path:String, buf:String, enc:system.text.Encoding)
    {
        if (HxEncoding.IsASCIIEncoding(enc)){
            PsggFile.WriteASCII(path,buf);
            return;
        }
        var bom = HxEncoding.ISUTF8Encoding_with_bom(enc);
        PsggFile.WriteUTF8(path,buf,bom);
    }
}