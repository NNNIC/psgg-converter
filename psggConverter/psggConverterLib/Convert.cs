using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;
using System.IO;

namespace psggConverterLib
{
    public partial class Convert
    {
        public bool   BRKGS     = false;  //  Breakpoint At Generate Source   
        public bool   BRKGF     = false;  //  Breakpoint At Generate Function
        public bool   BRKP      = false;  //  Breakpoint At Prepare

        public void   TEST()      { Console.WriteLine("psggConvertLib TEST");}

        public string VERSION()   { return ver.version;    }
        public string GITHASH()   { return githash.hash;   }
        public string BUILDTIME() { return ver.datetime;   }
        public string COPYRIGHT() { return "2018 NNNIC / MIT Licence"; }
        public string DEPOT()     { return ver.depot;      }

        public int    NAME_COL     =2;
        public int    STATE_ROW    =2;
        public string NEWLINECHAR  = "\x0d\x0a";

        //[Obsolete]
        //public string COMMMENTLINE_OBS = "//";

        public string COMMENTLINE_FORMAT  = "// {%0}";

        public string LANG         = "";
        public string OUTPUT       = "";
        public string ENC          = "utf-8";
        public string GENDIR       = "";
        public string XLSDIR       = ""; //エクセルファイル、マクロ等
        public string INCDIR       = ""; //インクルードマクロ用
        public string TEMSRC       = ""; //specify another template source.
        public string TEMFUNC      = ""; //specify another template function.
        public string PREFIX       = ""; //for another template souce and function.

        public string TEMSRC_save  = "";  //save TEMSRC for clear
        public string TEMFUNC_save = "" ; //save TEMFUNC for clear

        public readonly string CONTENTS1  ="$contents1$";
        public readonly string CONTENTS2  ="$contents2$";
        public readonly string CONTENTS3  ="$contents3$";
        public readonly string PREFIXMACRO ="$prefix$";
        //public readonly string INCLUDEFILE= @"\$include:.+?\$"; //Regexp
        //public readonly string MACRO      = @"$MACRO:.+?\$";    //Regexp

        public string template_src; // buffer
        public string template_func;// buffer
        public Func<int,int,string> getChartFunc; // string = (row,col) Base 1,  as Excel Access
        public Func<string,string>  getMacroValueFunc; // get macro value

        public string setting_ini; // setting_ini text 使用保留

        public List<string> state_list;
        public List<int>    state_col_list;

        public List<string> name_list;
        public List<int>    name_row_list;

        #region init
        public void Init(
            string i_template_src, 
            string i_template_func,
            Func<int,int,string> i_getChartFunc,
            Func<string,string>  i_getMacroValueFunc = null
            )
        {
            template_src      = i_template_src;
            template_func     = i_template_func;
            getChartFunc      = i_getChartFunc;
            getMacroValueFunc = i_getMacroValueFunc;

            _init();
        }

        private void _init()
        {
            state_list     = new List<string>();
            state_col_list = new List<int>();

            name_list     = new List<string>();
            name_row_list = new List<int>();

            for(var c = 1; c <10000; c++)
            {
                var state = getChartFunc(STATE_ROW, c);
                if (!string.IsNullOrEmpty(state))
                {
                    if (RegexUtil.Get1stMatch(@"^[a-zA-Z_][a-zA-Z_0-9]*$",state)==state)
                    {
                        state_list.Add(state);
                        state_col_list.Add(c);
                    }
                }
            }

            for(var r = 1; r < 10000; r++)
            {
                var name = getChartFunc(r, NAME_COL);
                if (!string.IsNullOrEmpty(name))
                {
                    name_list.Add(name);
                    name_row_list.Add(r);
                }
            }
        }
        #endregion

        #region generate
        public void   GenerateSource(string excel, string gendir, string incdir)
        {
            INCDIR = incdir;
            GenerateSource(excel,gendir);
        }
        public void   GenerateSource(string excel, string gendir)
        {
            if(BRKGS)
            {
                System.Diagnostics.Debugger.Break();
            }
            //if(string.IsNullOrEmpty(INCDIR))
            //    INCDIR = gendir;

            var sm = new SourceControl();
            sm.G = this;
            sm.m_excel = excel;
            sm.m_gendir = gendir;

            _runSourceControl(sm,SourceControl.MODE.INIT);
            _runSourceControl(sm,SourceControl.MODE.CVT);

            return;
        }
        public void Prepare() // Prepare for converting
        {
            if(BRKP)
            {
                System.Diagnostics.Debugger.Break();
            }

            var sm = new SourceControl();
            sm.G = this;
            sm.m_excel = null;
            sm.m_gendir = null;

            _runSourceControl(sm,SourceControl.MODE.INIT);
        }

        private static void _runSourceControl(SourceControl sm, SourceControl.MODE mode)
        {
            sm.mode = mode;
            
            sm.Start();
            for(var loop = 0;loop <= 10000;loop++)
            {
                if(loop == 10000)
                    throw new SystemException("Unexpected! {96B6D10A-FFF4-4BD4-B9E0-C155CF2C16EB}");

                sm.update();

                if(sm.IsEnd())
                    break;
            }
        }


        public string CreateFunc(string state)
        {
            if (BRKGF)
            { 
                System.Diagnostics.Debugger.Break();
            }
            var sm = new FunctionControl();
            sm.G = this;
            sm.m_state = state;
            sm.Start();
            for(var loop=0;loop<=10000;loop++)
            {
                if (loop == 10000) throw new SystemException("Unexpected! {D5DF7922-8A36-4458-A4F4-7B80A240EB08}");
                sm.update();
                if (sm.IsEnd()) break;
            }
            return sm.m_result_src;
        }
        public bool createFunc_prepare(string state, ref List<string> lines)
        {
            if (lines == null) return false;              

            var findindex = -1;
            var targetlines = StringUtil.FindMatchedLines(lines,"<<<?",">>>",out findindex);
            if (targetlines == null) return false; 
            if (targetlines.Count < 2) throw new SystemException("Unexpected! {A6446D1F-DFD0-4A63-93C7-299265119AC7}");

            //存在を確認して、残すか消す

            var line0 = targetlines[0];
            var targetname = RegexUtil.Get1stMatch(@"(?!\<\<\<\?)(\w+)",line0);
            if (isExist(state, targetname))
            {
                var size = targetlines.Count;

                //先頭行と最終行の削除
                targetlines.RemoveAt(0);
                targetlines.RemoveAt(targetlines.Count-1);

                //変換したものに入れ替え
                lines = StringUtil.ReplaceLines(lines,findindex,size,targetlines);
            }
            else
            {
                lines.RemoveRange(findindex,targetlines.Count);
            }
            
            return true;
        }
        public bool createFunc_work(string state, ref List<string> lines)
        {
            if (lines == null) return false;

            for(var i = 0; i<lines.Count; i++)
            {
                var line = lines[i];
                var targetvalue = RegexUtil.Get1stMatch(@"\[\[.*?\]\]",line);
                if (!string.IsNullOrEmpty(targetvalue)) {
                    var name = targetvalue.Trim('[',']');
                    var replacevalue   = getString(state,name);
                    //var replacevalue2  = lang_work(LANG,name,replacevalue);
                    var replacevalue3  = get_line_macro_value(name,replacevalue); // @stateマクロがあれば、各行に適用する
 
                    var tmplines = StringUtil.ReplaceWordsInLine(line,targetvalue,replacevalue3);

                    lines.RemoveAt(i);
                    lines.InsertRange(i,tmplines);
                    return true;
                }
            }
            return false;
        }
        #endregion

        // --- tools
        public bool isExist(string state, string name)
        {
            var v = getString(state, name);
            return !string.IsNullOrWhiteSpace(v);     
        }
        public int getCol(string state)
        {
            var index = state_list.IndexOf(state);
            if (index >=0)
            {
                return state_col_list[index];
            }
            return -1;
        }
        public int getRow(string name)
        {
            var index = name_list.IndexOf(name);
            if (index >= 0)
            {
                return name_row_list[index];
            }
            return -1;
        }
        public string getString(string state, string name)
        {
            var col = getCol(state);
            var row = getRow(name);

            return getChartFunc(row,col);
        }
    }
}
