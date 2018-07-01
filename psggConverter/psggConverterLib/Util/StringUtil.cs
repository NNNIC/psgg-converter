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

    public static List<string> SplitTrim(string s, char separator)
    {
        if (s==null) return null;
        var tokens = s.Split(separator);
        var list = new List<string>();
        foreach(var t in tokens)
        {
            var t2 = t.Trim();
            list.Add(t2);
        }

        return list;
    }
    public static List<string> SplitTrimEnd(string s, char separator)
    {
        if (s==null) return null;
        var tokens = s.Split(separator);
        var list = new List<string>();
        foreach(var t in tokens)
        {
            var t2 = t.TrimEnd();
            list.Add(t2);
        }
        return list;
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
    public static List<string> CutEmptyLines(List<string> src)
    {
        if (src==null) return null;
        var list = new List<string>();
        foreach(var l in src)
        {
            if (string.IsNullOrWhiteSpace(l)) {
                continue;
            }
            list.Add(l);
        }
        return list;
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

    public static List<string> FindMatchedLines(List<string> lines, string firstmatch, string endmatch, out int firstline)
    {
        firstline = -1;
        if (lines==null) return null;

        var result = new List<string>();

        var bFirstMatchDone = false;
        for(var index = 0; index < lines.Count; index++)
        {
            var line = lines[index];

            if (!bFirstMatchDone)
            {
                if (line.Contains(firstmatch))
                {
                    bFirstMatchDone = true;
                    firstline = index;
                    result.Add(line);
                }
                continue;
            }
            else
            {
                result.Add(line);
                if (line.Contains(endmatch))
                {
                    return result;
                }
            }
        }

        if (bFirstMatchDone)
        {
            throw new SystemException("Can not find end-match");
        }
        return null;
    }
    public static List<string> ReplaceLines(List<string> src, int src_target_start, int src_target_size, List<string> rep)
    {
        if (src==null) return null;

        var result = new List<string>();
        for(var i = 0; i<src_target_start; i++)
        {
            result.Add(src[i]);
        }
        result.AddRange(rep);
        for(var i = src_target_start + src_target_size; i < src.Count; i++)
        {
            result.Add(src[i]);
        }
        return result;
    }
    /// <summary>
    /// 文字列中の対象文字を代替文字に入れ替える
    /// ※代替文字に改行が含まれていた場合、見栄えを調整する。この場合に複数行になる
    /// </summary>
    public static List<string> ReplaceWordsInLine(string line, string target, string replace, bool bTrimEnd=true)
    {
        if (string.IsNullOrEmpty(line))   throw new SystemException("Unexpected! {8F041B67-5F7C-4159-83BC-A0A20858C242}");
        if (string.IsNullOrEmpty(target)) throw new SystemException("Unexpected! {475F3A7E-03A0-4AE0-94AD-8668BDA5B217}");
        if (target.Trim()!=target)        throw new SystemException("Unexpected! {BC4E8F0B-5DAA-4ED5-9E75-98134929CF0B}");
        if (!line.Contains(target))       throw new SystemException("Unexpected! {D5C8183F-D166-4C6E-AB6B-2E7FD7155696}");
        
        var replace2 = string.Empty;
        if (!string.IsNullOrEmpty(replace))
        {
            replace2= replace.Trim();
        }
        var newline  = StringUtil.FindNewLineChar(replace2);
        if (newline==null) //1行
        {
            var tmp = line.Replace(target,replace2);
            return new List<string>() { tmp };
        }
        /*
            複数行
            if ([[hoge]]){ return; }
              v
              v
            if (
                hoge1
                hoge2
                 :
                        ){ return; }


        */
        List<string> replines = bTrimEnd ?   StringUtil.SplitTrimEnd(replace2,'\x0a') : StringUtil.SplitTrim(replace2,'\x0a');
        var firstspace  = RegexUtil.Get1stMatch(@"^\s",line);
        var targetindex = line.IndexOf(target);

        var result = new List<string>();

        //1. 第一行：ターゲット手前まで
        {
            var buf = line.Substring(0,targetindex);
            result.Add(buf);
        }
        //2. 代替文字列 先頭に "firstspace" と (targetindex - firstspace.length)分のスペース 
        foreach(var r in replines)
        {
            var buf = string.Empty;
            if (firstspace!=null)
            {
                buf += firstspace + new string(' ', targetindex - firstspace.Length);
            }
            else
            {
                buf += new string(' ', targetindex);
            }
            buf += r;
            result.Add(buf);
        }
        //3. 最終行：代替文字列と同様の空白、その後にlineのターゲット文字以降を挿入
        {
            var buf = string.Empty;
            if (firstspace!=null)
            {
                buf += firstspace + new string(' ', targetindex + target.Length - firstspace.Length);
            }
            else
            {
                buf += new string(' ', targetindex + target.Length);
            }            
            buf += line.Substring(targetindex + target.Length);
            result.Add(buf);
        }
        return result;
    }
    public static string LineToBuf(List<string> lines, string newlinechar=null)
    {
        if (newlinechar == null) newlinechar = "\n";
        var s = string.Empty;
        foreach(var l in lines)
        {
            if (!string.IsNullOrEmpty(s)) s+=newlinechar;
            s += l.TrimEnd();
        }
        return s;
    }
}
