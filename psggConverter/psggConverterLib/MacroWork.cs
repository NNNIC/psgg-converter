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
        public string       m_prefixpattern  = @"\$prefix\$";

        public string       m_error;
                            
        bool         m_bValid;
        bool         m_bInclude;
        bool         m_bPrefix;
        string       m_matchstr;   //
        string       m_filename;   // for include
        string       m_fileenc;    // file encoding
        string       m_macrovalue; // ie hoge(a,b);
        string       m_api;        // ie hoge
        List<string> m_args; // {a,b}

        public void Init()
        {
            m_error      = null;

            m_bValid     = false;
            m_bInclude   = false;
            m_bPrefix    = false;
            m_matchstr   = null;
            m_filename   = null;
            m_fileenc    = null;
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
                match = RegexUtil.Get1stMatch(m_prefixpattern,buf);
                if (!string.IsNullOrEmpty(match))
                {
                    m_bValid  = true;
                    m_bPrefix = true;
                    m_matchstr = match;
                }
                else {
                    match = RegexUtil.Get1stMatch(m_macropattern,buf);
                    if (!string.IsNullOrEmpty(match))
                    {
                        m_bValid   = true;
                        m_bInclude = false;
                        m_matchstr = match;

                        analyze_macro();
                    }
                }
            }
            return m_bValid;
        }
        void analyze_include()
        {
                                             // 0123456789
            //m_filename = m_matchstr.Substring(/*$include:*/9).TrimEnd('$');
            var str = m_matchstr.Substring(/*$include:*/9).TrimEnd('$');
            if (str.Contains(','))
            {
                var tokens = str.Split(',');
                if (tokens!=null && tokens.Length >=2)
                {
                    m_filename = tokens[0];
                    m_fileenc  = tokens[1];
                }
                else
                {
                    throw new SystemException("Unexpected! {A496CE7C-9F74-4D7A-A105-B9B469A349D0}");
                }
            }
            else
            {
                m_filename = str;
            }
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
        }
        public bool IsValid()
        {
            return  m_bValid;
        }
        public bool IsPrefix()
        {
            return m_bPrefix;
        }
        public bool IsInclude()
        {
            return m_bInclude;
        }
        public string GetIncludFilename()
        {
            return m_filename;
        }
        public string GetIncludeFileEnc()
        {
            return m_fileenc;
        }
        public string GetMatchStr()
        {
            return m_matchstr;
        }
        public string GetMacroname()
        {
            return m_api;
        }
        public List<string> GetArgValueList()
        {
            return m_args;
        }

        //埋込用文字列    引数はargpatternで取得した文字列
        public string GetArgValue(string argstr)
        {
            return GetArgValue(argstr, m_args);
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

        // 汎用コンバータ
        public static string Convert(string text, List<string> args)
        {
            var src = text;
            for(var loop = 0; loop<=100; loop++)
            {
                if (loop==100) throw new SystemException("Unexpected! {69EA9451-D50D-492B-9BD8-A42EFCFC3758}");
                var match = RegexUtil.Get1stMatch(m_argpattern,src);
                if (!string.IsNullOrEmpty(match))
                {
                    var val = GetArgValue(match,args);
                    src = src.Replace(match,val);
                    continue;
                }

                break;
            }
            return src;
        }
        public static string Convert(string text, string arg0, string arg1=null, string arg2=null)
        {
            if (string.IsNullOrEmpty(arg0))
            {
                return "(error: arg0 is null {2145EA6E-3B45-47FC-B9FD-B82F56E47D89})";
            }
            var args = new List<string>();
            args.Add(arg0);
            if (arg1!=null) args.Add(arg1);
            if (arg2!=null) args.Add(arg2);

            return Convert(text,args);
        }
    }
}
