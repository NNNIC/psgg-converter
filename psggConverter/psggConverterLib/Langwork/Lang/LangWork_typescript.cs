using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace psggConverterLib
{
    public partial class Convert
    {
        string lang_work_typescript(string name, string value)
        {
            if (string.IsNullOrEmpty(value)) return value;
            if (name == "branch")
            {
                var newlinechar = StringUtil.FindNewLineChar(value);
                var lines = StringUtil.SplitTrim(value,'\x0a');

                var s = string.Empty;
                foreach(var l in lines)
                {
                    if (string.IsNullOrWhiteSpace(l)) continue;
                    var api  = RegexUtil.Get1stMatch(@"^[a-zA-Z0-9_]+",l); 
                    var p    = RegexUtil.Get1stMatch(@"(?<=\()[a-zA-Z0-9_]+",l);
                    var api2 = "this." + api;
                    var p2   = "this." + p;

                    var l2 = RegexUtil.Replace1stMatch(l,@"^"+api,api2);
                    l2     = RegexUtil.Replace1stMatch(l2,@"(?<=\()"+p,p2); 
                   
                    if (!string.IsNullOrEmpty(s))  s+=newlinechar;
                    s+= l2;
                }
                return s;
            }

            return value;
        }
    }
}
