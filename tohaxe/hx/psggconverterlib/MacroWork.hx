package psggconverterlib;
using StringTools;
import system.*;
import anonymoustypes.*;

class MacroWork
{
    public static inline var m_includepattern:String = "\\$include:.+?\\$";
    public static inline var m_macropattern:String = "\\$macro:.+?\\$";
    public static inline var m_argpattern:String = "\\{%(~{0,1})\\d+\\}";
    public static inline var m_numpattern:String = "\\{%[Nn]\\}";
    public var m_prefixpattern:String = "\\$prefix\\$";
    public var m_statemachinepattern:String = "\\$statemachine\\$";
    public var m_state_machinepattern:String = "\\$state_machine\\$";
    public var m_stateMachinePattern:String = "\\$stateMachine\\$";
    public var m_StateMachinePattern:String = "\\$StateMachine\\$";
    public var m_error:String;
    var m_bValid:Bool = false;
    var m_bInclude:Bool = false;
    var m_bPrefix:Bool = false;
    var m_bStatemachine:Bool = false;
    var m_b_state_machine:Bool = false;
    var m_b_stateMachine:Bool = false;
    var m_b_StateMachine:Bool = false;
    var m_matchstr:String;
    var m_filename:String;
    var m_fileenc:String;
    var m_macrovalue:String;
    var m_api:String;
    var m_args:Array<String>;
    public function Init():Void
    {
        m_error = null;
        m_bValid = false;
        m_bInclude = false;
        m_bPrefix = false;
        m_matchstr = null;
        m_filename = null;
        m_fileenc = null;
        m_macrovalue = null;
        m_api = null;
        m_args = null;
    }
    public function CheckMacro(buf:String):Bool
    {
        var match:String = 