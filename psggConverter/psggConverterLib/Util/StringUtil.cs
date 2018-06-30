using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Drawing;

public class StringUtil
{
    static readonly string _0d0a = "\x0d\x0a";
    static readonly string _0a   = "\x0a";

    public static string[] SplitTrim(string s, char separator)
    {
        if (s==null) return null;
        var tokens = s.Split(separator);
        var list = new List<string>();
        foreach(var t in tokens)
        {
            var t2 = t.Trim();
            list.Add(t2);
        }

        return list.ToArray();
    }
    public static string[] SplitTrimEnd(string s, char separator)
    {
        if (s==null) return null;
        var tokens = s.Split(separator);
        var list = new List<string>();
        foreach(var t in tokens)
        {
            var t2 = t.TrimEnd();
            list.Add(t2);
        }
        return list.ToArray();
    }
    public static string CutEmptyLines(string s)
    {
        if (s==null) return null;
        var newlinechar = FindNewLineChar(s);
        if (newlinechar==null) return s; //改行コードがない

        var tokens = SplitTrimEnd(s,'\x0a');

        var list = new List<string>();
        foreach(var t in tokens)
        {
            if (string.IsNullOrWhiteSpace(t)) continue;
            list.Add(t);
        }
        var o = string.Empty;
        list.ForEach(i=> {
            if (!string.IsNullOrEmpty(o)) o+= newlinechar;
            o+=i;
        });
        return o;
    }
    public static string ConvertNewLineForExcel(string s)
    {
        if (s!=null)
        {
            if (FindNewLineChar(s) == _0d0a)
            { 
                return s.Replace(_0d0a,_0a);
            }
        }
        return s;
    }

    public static string FindNewLineChar(string s)
    {
        if (string.IsNullOrEmpty(s)) return null;
        if (s.Contains(_0d0a)) return _0d0a;
        if (s.Contains(_0a)) return _0a;
        return null;
    }

    public static string ConverNewLineCharForDisplay(string s)
    {
        if (s!=null)
        { 
            var srcnl = FindNewLineChar(s);
            if (srcnl == _0a)
            {
                return s.Replace(_0a,_0d0a);
            }
        }
        return s;
    }
}
