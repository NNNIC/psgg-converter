using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

public partial class FunctionControl  {

	public psggConverterLib.Convert G;	
    public string                   m_state;
    public bool                     IsEnd()     { return CheckState(S_END); }

    public string m_error       = string.Empty;
    bool          m_OkNG        = false;
    bool          m_needAgain   = false;

	public string m_result_src  = null;

    string        m_buf         = string.Empty;
    List<string>  m_lines       = null;
    //string        m_newLineChar = string.Empty;
    int           m_loopIndex   = 0;
    const int     m_loopMax     = 10000;
    void set_buf()
    {
        m_buf = G.template_func;
    }
    
    void split_buf()
    {
        var newlinechar = StringUtil.FindNewLineChar(m_buf);
        m_OkNG = newlinechar!=null;
        if (m_OkNG)
        {
            m_lines = StringUtil.SplitTrimEnd(m_buf,'\x0a');
        }
        else
        {
            m_error = "buffer not found! {E1BB5578-E9E5-4C46-ABE9-4152D3A1AB1C}";
        }
    }

    void loop_init()
    {
        m_loopIndex = 0;
    }

    void loop_check()
    {
        m_OkNG = m_loopIndex < m_loopMax;
        if (!m_OkNG)
        {
            m_error = "Loop reached max number! {7C91FBD1-C711-488F-983E-EC0E4008D69D}";
        }
    }

    void preprocess()
    {
        m_OkNG = true;
        try { 
            m_needAgain = G.createFunc_prepare(m_state,ref m_lines);
        }
        catch (SystemException e)
        {
            m_error = e.Message;
            m_OkNG = false;
        }
    }

    void set_value()
    {
        m_OkNG = true;
        try
        {
            m_needAgain = G.createFunc_work(m_state, ref m_lines);
        }
        catch (SystemException e)
        {
            m_error = e.Message;
            m_OkNG = false;
        }
    }

    #region branch
    void br_OK(Action<bool> st)
    {
        if (m_OkNG) SetNextState(st);
    }
    void br_NG(Action<bool> st)
    {
        if (!m_OkNG) SetNextState(st);
    }
    void br_NeedAgain(Action<bool> st)
    {
        if (m_needAgain) SetNextState(st);
    }
    #endregion


}
