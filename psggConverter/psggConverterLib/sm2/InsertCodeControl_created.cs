//  psggConverterLib.dll converted from InsertCodeControl.xlsx. 
using System;
public partial class InsertCodeControl : StateManager {

    public override void Start()
    {
        Goto(S_START);
    }
    public override bool IsEnd()
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
