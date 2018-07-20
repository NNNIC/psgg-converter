using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace psggConverterLib
{
    public partial class Convert
    {
        string lang_work(string lang, string name, string value)
        {
            if (lang == "typescript") return lang_work_typescript(name, value);
            if (lang == "vba")        return lang_work_vba(name, value);
            return value;
        }

    }
}
