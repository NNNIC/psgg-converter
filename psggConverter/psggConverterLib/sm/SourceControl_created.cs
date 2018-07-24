// psggConverterLib.dll converted from SourceControl.xlsx. 
public partial class SourceControl : StateManager {

    public void Start()
    {
        Goto(S_START);
    }


    /*
        S_START
    */
    void S_START(bool bFirst)
    {
        if (bFirst)
        {
        }
        if (!HasNextState())
        {
            SetNextState(S_LOADSETTING);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    /*
        S_END
    */
    void S_END(bool bFirst)
    {
        if (bFirst)
        {
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    /*
        S_LOADSETTING
        設定読込み
    */
    void S_LOADSETTING(bool bFirst)
    {
        if (bFirst)
        {
            load_setting();
        }
        if (!HasNextState())
        {
            SetNextState(S_SETLANG);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    /*
        S_SETLANG
        言語設定
    */
    void S_SETLANG(bool bFirst)
    {
        if (bFirst)
        {
            set_lang();
        }
        if (!HasNextState())
        {
            SetNextState(S_WRITEHEDDER);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    /*
        S_WRITEHEDDER
        ヘッダ―記入
    */
    void S_WRITEHEDDER(bool bFirst)
    {
        if (bFirst)
        {
            write_header();
        }
        if (!HasNextState())
        {
            SetNextState(S_CREATESOURCE);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    /*
        S_CREATESOURCE
        ソース生成
    */
    void S_CREATESOURCE(bool bFirst)
    {
        if (bFirst)
        {
            create_source();
        }
        if (!HasNextState())
        {
            SetNextState(S_WRITEFILE);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    /*
        S_WRITEFILE
        ファイル書込み
    */
    void S_WRITEFILE(bool bFirst)
    {
        if (bFirst)
        {
            write_file();
        }
        if (!HasNextState())
        {
            SetNextState(S_END);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }

}

