using System;
using System.Collections.Generic;
public partial class CfPrepareControl  {
   
    #region manager
    Action<bool> m_curfunc;
    Action<bool> m_nextfunc;

    bool         m_noWait;
    
    public void Update()
    {
        while(true)
        {
            var bFirst = false;
            if (m_nextfunc!=null)
            {
                m_curfunc = m_nextfunc;
                m_nextfunc = null;
                bFirst = true;
            }
            m_noWait = false;
            if (m_curfunc!=null)
            {   
                m_curfunc(bFirst);
            }
            if (!m_noWait) break;
        }
    }
    void Goto(Action<bool> func)
    {
        m_nextfunc = func;
    }
    bool CheckState(Action<bool> func)
    {
        return m_curfunc == func;
    }
    bool HasNextState()
    {
        return m_nextfunc != null;
    }
    void NoWait()
    {
        m_noWait = true;
    }
    #endregion
    #region gosub
    List<Action<bool>> m_callstack = new List<Action<bool>>();
    void GoSubState(Action<bool> nextstate, Action<bool> returnstate)
    {
        m_callstack.Insert(0,returnstate);
        Goto(nextstate);
    }
    void ReturnState()
    {
        var nextstate = m_callstack[0];
        m_callstack.RemoveAt(0);
        Goto(nextstate);
    }
    #endregion 

    public void Start()
    {
        Goto(S_START);
    }
    public bool IsEnd()     
    { 
        return CheckState(S_END); 
    }
    
    public void Run()
    {
		int LOOPMAX = (int)(1E+5);
		Start();
		for(var loop = 0; loop <= LOOPMAX; loop++)
		{
			if (loop>=LOOPMAX) throw new SystemException("Unexpected.");
			if (IsEnd()) break;
			
			Update();
		}
	}

	#region    // [PSGG OUTPUT START] indent(8) $/./$
//  psggConverterLib.dll converted from CfPrepareControl.xlsx. 
        /*
            E_0003
        */
        int m_indindex;
        List<string> m_targetlines = null;
        /*
            E_0005
        */
        string m_line0;
        bool   m_bValid;
        string m_itemname;
        string m_regex;
        string m_target;
        /*
            E_INOUT
        */
        public string m_state;
        public List<string> m_lines;
        public bool m_bResult;
        /*
            S_CHECK_BOT
            ターゲットの先頭文字
        */
        void S_CHECK_BOT(bool bFirst)
        {
            var c = m_target[0];
            // branch
            if (c=='\"') { Goto( S_STR_W_REGEX ); }
            else { Goto( S_ITEM_W_REGEX ); }
        }
        /*
            S_CHECK_EXCEPTION
        */
        void S_CHECK_EXCEPTION(bool bFirst)
        {
            //
            if (bFirst)
            {
                if (m_targetlines.Count < 2) throw new SystemException("Unexpected! {A6446D1F-DFD0-4A63-93C7-299265119AC7}");
            }
            //
            if (!HasNextState())
            {
                Goto(S_INIT2);
            }
        }
        /*
            S_CHECK_LINES
        */
        void S_CHECK_LINES(bool bFirst)
        {
            // branch
            if (m_lines==null) { Goto( S_RETURN_FALSE ); }
            else { Goto( S_FIND_MATCHLINES ); }
        }
        /*
            S_END
        */
        void S_END(bool bFirst)
        {
        }
        /*
            S_FIND_MATCHLINES
            ＜＜＜？～＞＞＞に囲まれたバッファ抽出
        */
        void S_FIND_MATCHLINES(bool bFirst)
        {
            //
            if (bFirst)
            {
                m_findindex = -1;
                m_targetlines = StringUtil.FindMatchedLines2(m_lines, "<<<?", ">>>", out m_findindex);
            }
            // branch
            if (m_findlines==null) { Goto( S_RETURN_FALSE ); }
            else { Goto( S_CHECK_EXCEPTION ); }
        }
        /*
            S_INIT2
        */
        void S_INIT2(bool bFirst)
        {
            //
            if (bFirst)
            {
                m_lines0=m_targetlines[0];
                m_bValid = false;
                m_itemname = string.Empty;
                m_regex = string.Empty;
            }
            //
            if (!HasNextState())
            {
                Goto(S_TARGET);
            }
        }
        /*
            S_ITEM_W_REGEX
            ＜＜＜？itemname/正規表現/
        */
        void S_ITEM_W_REGEX(bool bFirst)
        {
            //
            if (bFirst)
            {
                m_itemname = RegexUtil.Get1stMatch(@"[0-9a-zA-Z_\-]+", m_target);
                m_regex = m_target.Substring(m_itemname.Length);
                m_val = getString2(m_state, m_itemname);
            }
        }
        /*
            S_RETURN_FALSE
        */
        void S_RETURN_FALSE(bool bFirst)
        {
            //
            if (bFirst)
            {
                m_bResult = false;
            }
            //
            if (!HasNextState())
            {
                Goto(S_END);
            }
        }
        /*
            S_START
        */
        void S_START(bool bFirst)
        {
            //
            if (!HasNextState())
            {
                Goto(S_CHECK_LINES);
            }
        }
        /*
            S_STR_W_REGEX
            ＜＜＜？"文字列"/正規表現/
        */
        void S_STR_W_REGEX(bool bFirst)
        {
            //
            if (bFirst)
            {
                var dqw= RegexUtil.Get1stMatch(@"".*"",m_target);
                m_val = dqw.Trim('"');
                m_regex = target.Substring(dqw.Length);
            }
        }
        /*
            S_TARGET
            ＜＜＜？のターゲットを取得
        */
        void S_TARGET(bool bFirst)
        {
            //
            if (bFirst)
            {
                m_target = RegexUtil.Get1stMatch(@"\<\<\<\?.+\s*$",m_line0);
                m_target = m_target.Substring(4).Trim(); // ＜＜＜？を削除
            }
            //
            if (!HasNextState())
            {
                Goto(S_CHECK_BOT);
            }
        }


	#endregion // [PSGG OUTPUT END]

	// write your code below

	bool m_bYesNo;
	
	void br_YES(Action<bool> st)
	{
		if (!HasNextState())
		{
			if (m_bYesNo)
			{
				Goto(st);
			}
		}
	}

	void br_NO(Action<bool> st)
	{
		if (!HasNextState())
		{
			if (!m_bYesNo)
			{
				Goto(st);
			}
		}
	}
}

/*  :::: PSGG MACRO ::::
:psgg-macro-start

commentline=// {%0}

@branch=@@@
<<<?"{%0}"/^brifc{0,1}$/
if ([[brcond:{%N}]]) { Goto( {%1} ); }
>>>
<<<?"{%0}"/^brelseifc{0,1}$/
else if ([[brcond:{%N}]]) { Goto( {%1} ); }
>>>
<<<?"{%0}"/^brelse$/
else { Goto( {%1} ); }
>>>
<<<?"{%0}"/^br_/
{%0}({%1});
>>>
@@@

:psgg-macro-end
*/

