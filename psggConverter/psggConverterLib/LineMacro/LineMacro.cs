using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace psggConverterLib
{
    public partial class Convert
    {
        //var replacevalue3  = get_line_macro_value(namereplacevalue2);
        string get_line_macro_value(string name, string s)
        {
            var macrovalue = getMacroValueFunc("@" + name);
            if (string.IsNullOrEmpty(macrovalue)) return s; //null時は、変更なし

            var lines = StringUtil.SplitTrim(s,'\x0a');
            var result = new List<string>();


            // 各ラインを args に変換
            // カンマ区切りはその通りに args
            // api(a,b..)は api を arg0 として
            foreach(var l in lines)
            { 
                if (string.IsNullOrEmpty(l)) continue;

                string api;
                List<string > args;
                string error;

                StringUtil.SplitApiArges(l,out api, out args, out error);
                if (!string.IsNullOrEmpty(error) || api.Contains(","))
                {// カンマリストとみなす
                    api = null;
                    args = StringUtil.SplitComma(l);
                }
                else
                {
                    args.Insert(0,api);
                    api = null;
                }
                // この時点で argsリスト完成
                var text = macrovalue;
                for(var loop = 0; loop<=100; loop++)
                {
                    if (loop==100) throw new SystemException("Unexpected! {4ACD9F85-8663-4241-ABB2-E2E96EFD84F0}");
                    var match = RegexUtil.Get1stMatch(MacroWork.m_argpattern,text);
                    if (!string.IsNullOrEmpty(match))
                    { 
                        var value = MacroWork.GetArgValue(match,args);
                        text = text.Replace(match,value);
                        continue;
                    }
                    break;
                }
                result.Add(text);
            }

            return StringUtil.LineToBuf(result,NEWLINECHAR);
        }
    }
}
