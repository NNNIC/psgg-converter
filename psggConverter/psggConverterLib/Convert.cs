using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace psggConverterLib
{
    public class Convert
    {
        public void   TEST()      { Console.WriteLine("psggConvertLib TEST");}
        public string VERSION()   { return ver.version;    }
        public string GITHASH()   { return githash.hash;   }
        public string BUILDTIME() { return ver.datetime;   }
        public string COPYRIGHT() { return "2018 NNNIC / MIT Licence"; }
        public string DEPOT()     { return ver.depot;      }

        public int NAME_COL  =2;
        public int STATE_ROW =2;
        public string NEWLINECHAR  = "\x0d\x0a";
        public string COMMMENTLINE = "//";
        public string LANG = "";

        public readonly string CONTENTS1="$contents1$";
        public readonly string CONTENTS2="$contents2$";
        public readonly string CONTENTS3="$contents3$";

        public string template_src;
        public string template_func;
        public Func<int,int,string> getChartFunc; // string = (row,col) Base 1,  as Excel Access

        public List<string> state_list;
        public List<int>    state_col_list;

        public List<string> name_list;
        public List<int>    name_row_list;

        public void Init(
            string i_template_src, 
            string i_template_func,
            Func<int,int,string> i_getChartFunc
            )
        {
            template_src = i_template_src;
            template_func = i_template_func;
            getChartFunc  = i_getChartFunc;

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

        public string CreateSource()
        {
            // contents
            var contents1 = string.Empty;
            {
                var s = string.Empty;
                foreach(var state in this.state_list)
                {
                    s += state + ",";
                }
                contents1 = s;
            }
            var contents2 = string.Empty;
            {
                var s = string.Empty;
                foreach(var state in this.state_list)
                {
                    s += CreateFunc(state) + NEWLINECHAR;
                }
                contents2 = s;
            }
            
            //
            var resultlist = new List<string>();
            var lines = StringUtil.SplitTrimEnd(template_src,'\x0a');
            for(var i=0; i<lines.Count; i++)
            {
                var line = lines[i];

                if (line.Length >0 && line[0] == ':') continue;

                if (line.Contains(CONTENTS1))
                {
                    var tmplines = StringUtil.ReplaceWordsInLine(line,CONTENTS1,contents1);
                    resultlist.AddRange(tmplines);
                    continue;
                }
                if (line.Contains(CONTENTS2))
                {
                    var tmplines = StringUtil.ReplaceWordsInLine(line,CONTENTS2,contents2);
                    resultlist.AddRange(tmplines);
                    continue;
                }
                resultlist.Add(line);
            }

            return StringUtil.LineToBuf(lines,NEWLINECHAR);

        }

        public string CreateFunc(string state)
        {
            var buf = template_func;
            var newlinechar = StringUtil.FindNewLineChar(buf);
            if (newlinechar == null) {
                return null;
            }
            var lines = StringUtil.SplitTrimEnd(buf,'\x0a');

            for(var loop = 0; loop<=10000; loop++)
            {
                if (loop == 10000) throw new SystemException("Unexpected! {C9B57B4C-8B37-4FC8-8761-CE9F2C9A2F8D}");

                if (createFunc_prepare(state,ref lines))
                {
                    continue;
                }            
                else
                {
                    break;
                }    
            }

            lines = StringUtil.CutEmptyLines(lines);

            for(var loop = 0; loop<=10000; loop++)
            {
                if (loop == 10000) throw new SystemException("Unexpected! {5EE861CB-72C8-4F97-B753-493C73906964}");
                if (createFunc_work(state, ref lines))
                {
                    continue;
                }
                else
                {
                    break;
                }
            }

            lines = StringUtil.CutEmptyLines(lines);

            return StringUtil.LineToBuf(lines,NEWLINECHAR);
        }
        private bool createFunc_prepare(string state, ref List<string> lines)
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
        private bool createFunc_work(string state, ref List<string> lines)
        {
            if (lines == null) return false;

            for(var i = 0; i<lines.Count; i++)
            {
                var line = lines[i];
                var targetvalue = RegexUtil.Get1stMatch(@"\[\[.*?\]\]",line);
                if (!string.IsNullOrEmpty(targetvalue)) {
                    var name = targetvalue.Trim('[',']');
                    var replacevalue = getString(state,name);
                    var tmplines = StringUtil.ReplaceWordsInLine(line,targetvalue,replacevalue);

                    lines.RemoveAt(i);
                    lines.InsertRange(i,tmplines);
                    return true;
                }
            }
            return false;
        }
        

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
