package start;
import tool.IniUtil;
import psggconverterlib.Convert;
class Program {
    public static function main() {
        trace("#0. call Convert");
        var p = new Convert();
        p.TEST();

        trace("\n#1. test RegexUtil.IsMatch");

        var r = RegexUtil.IsMatch("^HOGE$","HOGE");
        trace("RegexUtil.IsMatch(\"^HOGE$\",\"HOGE\")->" + r);
        r = RegexUtil.IsMatch("^HOGE$","HEGE");
        trace("RegexUtil.IsMatch(\"^HOGE$\",\"HEGE\")->" + r);
        r = RegexUtil.IsMatch("^H_.*$","H_EGE");
        trace("RegexUtil.IsMatch(\"^H_.*$\",\"H_EGE\")->" + r);
        
        trace("\n#2 Get1stMatch");
        
        var s = RegexUtil.Get1stMatch("_._","xxxx_n_v_c_");
        trace("RegexUtil.Get1stMatch(\"_._\",xxxx_n_v_c_\")->" + s);
        s = RegexUtil.Get1stMatch("^A_.*","A_xxxx_n_v_c_");
        trace("RegexUtil.Get1stMatch(\"$A_.*\",\"A_xxxx_n_v_c_\")->" + s);

        trace("\n#3 GetNthMatch");
        var m0 = RegexUtil.GetNthMatch("_._","xxxx_n__v__c_",0);
        var m1 = RegexUtil.GetNthMatch("_._","xxxx_n__v__c_",1);
        var m2 = RegexUtil.GetNthMatch("_._","xxxx_n__v__c_",2);
        var m3 = RegexUtil.GetNthMatch("_._","xxxx_n__v__c_",3);

        trace("RegexUtil.GetNstMatch(\"_._\",\"xxxx_n__v__c_\",[0..3)" + m0 + ","+ m1 + ","+ m2 + ","+ m3 + "," );

        trace("\n#4 Array<String>.sort");
        var l = ["dog","cat","mouse","monkey","sheep","tiger"];
        var l2 = SortUtil.Sort(l);
        for(i in l2) {
            trace(i);
        }

        trace("\n#5 Encoding ascii");
        var asciienc1 = new system.text.ASCIIEncoding();
        var asciienc2 = psgg.HxEncoding.GetEncoding_String("ascii");
        trace("asciienc1 : IsAscii -> " + psgg.HxEncoding.IsASCIIEncoding(asciienc1) );
        trace("asciienc2 : IsAscii -> " + psgg.HxEncoding.IsASCIIEncoding(asciienc2) );
        trace("asciienc1 : IsUtf8  -> " + psgg.HxEncoding.IsUTF8Encoding(asciienc1) );
        trace("asciienc2 : IsUtf8  -> " + psgg.HxEncoding.IsUTF8Encoding(asciienc2) );

        trace("\n#6 Encoding utf8");
        var utf8enc1 = new system.text.UTF8Encoding();
        var utf8enc2 = new psgg.HxUTF8Encoding(true);
        var utf8enc3 = new psgg.HxUTF8Encoding(false);
        var utf8enc4 = psgg.HxEncoding.GetEncoding_String("utf8");
        trace("utf8enc1 : IsUTF8 -> " + psgg.HxEncoding.IsUTF8Encoding(utf8enc1) );
        trace("utf8enc2 : IsUTF8 -> " + psgg.HxEncoding.IsUTF8Encoding(utf8enc2) );
        trace("utf8enc3 : IsUTF8 -> " + psgg.HxEncoding.IsUTF8Encoding(utf8enc3) );
        trace("utf8enc4 : IsUTF8 -> " + psgg.HxEncoding.IsUTF8Encoding(utf8enc4) );
        trace("asciienc1: IsUTF8 -> " + psgg.HxEncoding.IsUTF8Encoding(asciienc1) );
        trace("utf8enc2 : IsUTF8wBOM -> " + psgg.HxEncoding.ISUTF8Encoding_with_bom(utf8enc2) );
        trace("utf8enc3 : IsUTF8wBOM -> " + psgg.HxEncoding.ISUTF8Encoding_with_bom(utf8enc3) );

        trace("\n#7 Read File ファイル読込");
        trace("Read : utf8-wbom.txt "  + PsggFile.ReadUTF8("C:/Users/gea01/Documents/psgg/psgg-converter/tohaxe/testdata/utf8-wbom.txt"));
        trace("Read : utf8-wobom.txt " + PsggFile.ReadUTF8("C:/Users/gea01/Documents/psgg/psgg-converter/tohaxe/testdata/utf8-wobom.txt"));

        trace("\n\n CONVERTER TEST");
        
        var cc = new ConvControl();
        cc.m_psgg_file = "C:/Users/gea01/Documents/psgg/psgg-converter/tohaxe/testdata/win-bat/MainControl.psgg";
        cc.Run();

        trace("\n#8 ini test");
        trace("X=" + IniUtil.Get("X=GORO","X"));
        trace("X=" + IniUtil.Get("X=@@@\nSTART\nHOGE\nEND\n@@@","X"));


    }
}