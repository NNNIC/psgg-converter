using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace psggConverterLib
{
    public class Access
    {
        public int NAME_COL  =2;
        public int STATE_ROW =2;

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

        public string weave(string state)
        {
            var buf = template_func;

            for(var loop = 0; loop<=10000; loop++)
            {
                if (loop == 10000) throw new SystemException("Unexpected! {C9B57B4C-8B37-4FC8-8761-CE9F2C9A2F8D}");

                bool bNeedLoop = false;

                //var pattern = @"\<\<\<\?[\s\S]+?\>\>\>";  //@"\<\<\<\?([\s\S]|(?!\<\<\<))+\>\>\>"; // <<<? ～ >>> 但し中に <<<がない
                //var regex = new Regex(pattern);
                //var matches = regex.Matches(buf);
                //if (matches!=null && matches.Count>0)
                //{
                //    Match match = null;
                //    foreach(var m in matches)
                //    {
                //        match = (Match)m;
                //        break;
                //    }

                //    var targetname = RegexUtil.Get1stMatch(@"\w+",match.Value);
                //    if (isExist(state,targetname))
                //    {

                //    }

                //}
            }
                        
        }
        private bool weave_sub1(string state, ref string s)
        {


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
