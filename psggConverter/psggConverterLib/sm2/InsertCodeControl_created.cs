//  psggConverterLib.dll converted from InsertCodeControl.xlsx. 
using System;
public partial class InsertCodeControl : StateManager {

    public void Start()
    {
        Goto(S_START);
    }
    public bool IsEnd()
    {
        return CheckState(S_END);
    }



    /*
        S_END
    */
    void S_END(bool bFirst)
    {
        //
        if (HasNextState())
        {
            GoNextState();
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
            SetNextState(S_END);
        }
        //
        if (HasNextState())
        {
            GoNextState();
        }
    }

}
