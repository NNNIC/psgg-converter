using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace psggConverterLib
{
    // call from macrocontrol and sourcecontrol
    public class MacroWork
    {
        public const string m_includepattern = @"\$include:.+?\$";
        public const string m_macropattern   = @"\$macro:.+?\$";
        public const string m_argpattern     = @"\{%(~{0,1})\d+\}";   //埋め込み側の引数パターン  {%0} または {%~0}  チルダ(~)があると文字列両端のダブルクォートを削除する

        public string       m_error;
                            
        bool         m_bValid;
        bool         m_bInclude;
        string       m_matchstr;   //
        string       m_filename;   // for include
        string       m_macrovalue; // ie hoge(a,b);
        string       m_api;        // ie hoge
        List<string> m_args; // {a,b}

        public void Init()
        {
            m_error      = null;

            m_bValid     = false;
            m_bInclude   = false;
            m_matchstr   = null;
            m_filename   = null;
            m_macrovalue = null;
            m_api        = null;
            m_args       = null;

        }

        public bool CheckMacro(string buf)
        {
            string match = RegexUtil.Get1stMatch(m_includepattern,buf);
            if (!string.IsNullOrEmpty(match))
            {
                m_bValid = true;
                m_bInclude = true;
                m_matchstr = match;

                analyze_include();
            }
            else
            {
                match = RegexUtil.Get1stMatch(m_macropattern,buf);
                if (!string.IsNullOrEmpty(match))
                {
                    m_bValid   = true;
                    m_bInclude = false;
                    m_matchstr = match;

                    analyze_macro();
                }
            }
            return m_bValid;
        }
        void analyze_include()
        {
                                             // 0123456789
            m_filename = m_matchstr.Substring(/*$include:*/9).TrimEnd('$');
        }
        void analyze_macro()
        {                                       //01234567
            m_macrovalue = m_matchstr.Substring(/*$macro:*/7).TrimEnd('$');
            string api;
            List<string> args;
            string error;
            StringUtil.SplitApiArges(m_macrovalue,out api, out args, out error);
            m_api = api;
            m_args = args;
            m_error = error;
            //var sp = m_macrovalue.IndexOf('(');
            //if (sp < 0 )
            //{
            //    m_api = m_macrovalue;
            //    return;
            //}
            //m_api = m_macrovalue.Substring(0,sp);
            //var argstr = m_macrovalue.Substring(sp).Trim();
            //if (!RegexUtil.IsMatch(@"^\(.*\)\s*$",argstr))
            //{
            //    m_error  = "arg string is invalid.";
            //    return;
            //}
            //var arglist = StringUtil.SplitComma(argstr);
            //if (arglist==null)
            //{
            //    m_error = "unexpected! {87753187-4E54-4E2D-A445-239002F2E59A}";
            //    return;
            //}
            //m_args = arglist;
        }
        public bool IsValid()
        {
            return  m_bValid;
        }
        public bool IsInclude()
        {
            return m_bInclude;
        }
        public string GetIncludFilename()
        {
            return m_filename;
        }
        public string GetMatchStr()
        {
            return m_matchstr;
        }
        public string GetMacroname()
        {
            return m_api;
        }

        //埋込用文字列    引数はargpatternで取得した文字列
        public string GetArgValue(string argstr)
        {
            return GetArgValue(argstr, m_args);
            //if (m_args==null) return "<!!" + argstr.Trim('<','>') +  "(error:no args in macro)!!>"; //変換できず。
            //if (!RegexUtil.IsMatch(m_argpattern,argstr))
            //{
            //    throw new SystemException("Unexpected! {0A4A6F44-838E-44D4-8CCA-873C26573E6B}");
            //}
            //var numstr = RegexUtil.Get1stMatch(@"\d+",argstr);
            //var num = int.Parse(numstr);
            //var bDqOff = argstr.Contains("~");

            //if (num>=m_args.Count) return "<!!" + argstr.Trim('<','>') + "(error: arg num is grater than args count)!!>"; //変換できず
            //var v = m_args[num];
            //if (bDqOff)
            //{
            //    v = v.Trim('\"');
            //}
            //return v;
        }

        // 別からも利用できるように static化
        public static string GetArgValue(string argstr, List<string> args)
        {
            if (args==null) return "<!!" + argstr.Trim('<','>') +  "(error:no args in macro)!!>"; //変換できず。
            if (!RegexUtil.IsMatch(m_argpattern,argstr))
            {
                throw new SystemException("Unexpected! {0A4A6F44-838E-44D4-8CCA-873C26573E6B}");
            }
            var numstr = RegexUtil.Get1stMatch(@"\d+",argstr);
            var num = int.Parse(numstr);
            var bDqOff = argstr.Contains("~");

            if (num>=args.Count) return "<!!" + argstr.Trim('<','>') + "(error: arg num is grater than args count)!!>"; //変換できず
            var v = args[num];
            if (bDqOff)
            {
                v = v.Trim('\"');
            }
            if (string.IsNullOrEmpty(v))
            {
                v = "<!!" + argstr.Trim('<','>') + "(error: arg is null)!!>"; 
            }
            return v;
        }

    }
}
