using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

/* ------------------------------
 * 
 * 作成日：24/03/18
 * 更新日：24/03/18
 * 作成者：宮﨑智也
 * 
 * 2024/03/18
 * デッドゾーンを用いたスティック値を
 * Int型で送る関数を作成しました
 * 
 * --------------------------- */

public class ControlManager : MonoBehaviour
{
    [SerializeField] private bool isDebug = false;

    /* 列挙体宣言 */
    public enum E_TYPE
    {
        PRESSED,    // 押した
        RELEASED,   // 離した
        HOLDPRESS,  // 押している
    }

    // ゲームパッドボタンの列挙
    public enum E_GP
    {
        A,
        B,
        X,
        Y,
        UP,
        DOWN,
        LEFT,
        RIGHT,
        LB,
        RB,
        START,
        SELECT,
        LSTICK,
        RSTICK,
    }

    // キーボードの列挙
    public enum E_KB
    {
        A,
        B,
        C,
        D,
        E,
        F,
        G,
        H,
        I,
        J,
        K,
        L,
        M,
        N,
        O,
        P,
        Q,
        R,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z,
        UP,
        DOWN,
        LEFT,
        RIGHT,
        L_SHIFT,
        R_SHIFT,
        SPACE,
        ENTER,
        ESCAPE,
    }

    // 左右情報の列挙
    public enum E_DIRECTION
    {
        LEFT,
        RIGHT,
    }

    // 直交座標系
    public enum E_COORDINATE
    {
        VERTICAL,   // 垂直
        HORIZONTAL, // 水平
    }

    private void Update()
    {
        /* デバッグしないなら処理を抜ける */
        if (!isDebug) return;

        Debug.Log("片方をいんとでとるよー：左Hori" + GetStickIntegerValue(E_DIRECTION.LEFT, E_COORDINATE.VERTICAL));
        Debug.Log("片方をいんとでとるよー：左Vart" + GetStickIntegerValue(E_DIRECTION.LEFT, E_COORDINATE.HORIZONTAL));
        Debug.Log("片方をいんとでとるよー：右Hori" + GetStickIntegerValue(E_DIRECTION.RIGHT, E_COORDINATE.VERTICAL));
        Debug.Log("片方をいんとでとるよー：右Vart" + GetStickIntegerValue(E_DIRECTION.RIGHT, E_COORDINATE.HORIZONTAL));

        Debug.Log("片方とるよー：左Hori" + GetStickValue(E_DIRECTION.LEFT, E_COORDINATE.VERTICAL));
        Debug.Log("片方とるよー：左Vart" + GetStickValue(E_DIRECTION.LEFT, E_COORDINATE.HORIZONTAL));
        Debug.Log("片方とるよー：右Hori" + GetStickValue(E_DIRECTION.RIGHT, E_COORDINATE.VERTICAL));
        Debug.Log("片方とるよー：右Vart" + GetStickValue(E_DIRECTION.RIGHT, E_COORDINATE.HORIZONTAL));

        Debug.Log("ひだり　とりがー！" + GetTriggerValue(E_DIRECTION.LEFT));
        Debug.Log("みぎ　　とりがー！" + GetTriggerValue(E_DIRECTION.RIGHT));

        Debug.Log("両方取るよー" + GetStickValue(E_DIRECTION.LEFT));
        Debug.Log("両方取るよー" + GetStickValue(E_DIRECTION.RIGHT));
    }

    public bool GetConnect()
    {
        if(Gamepad.current == null) return false;

        return true;
    }

    /* 指定されたスティックの傾きを整数で返す */
    public int GetStickIntegerValue(E_DIRECTION _dir,E_COORDINATE _cor, float _deadzone = 0.0f)
    {
        // ゲームパッドが接続されていなければ処理を抜ける
        if (Gamepad.current == null) return 0;

        double tiltValue = 0.0f;

        switch (_dir)
        {
            case E_DIRECTION.LEFT:
                {
                    switch (_cor)
                    {
                        case E_COORDINATE.VERTICAL:     tiltValue = Gamepad.current.leftStick.ReadValue().y; break;
                        case E_COORDINATE.HORIZONTAL:   tiltValue = Gamepad.current.leftStick.ReadValue().x; break;
                    }

                    break;
                }
            case E_DIRECTION.RIGHT:
                {
                    switch (_cor)
                    {
                        case E_COORDINATE.VERTICAL:     tiltValue  =Gamepad.current.rightStick.ReadValue().y; break;
                        case E_COORDINATE.HORIZONTAL:   tiltValue  =Gamepad.current.rightStick.ReadValue().x; break;
                    }

                    break;
                }
        }

        if (tiltValue > _deadzone)
        {
            return 1;
        }
        else if (tiltValue < -_deadzone)
        {
            return -1;
        }

        return 0;
    }

    /* 指定された直交片方のキー入力を返す */
    public int GetWASD_IntegerValue(E_COORDINATE _cor)
    {
        int mov = 0;

        switch(_cor)
        {
            case E_COORDINATE.VERTICAL:
                {
                    /* 上下の入力状態を送る */
                    if(GetHoldPress(E_KB.W)) mov = 1;
                    if(GetHoldPress(E_KB.S)) mov = -1;

                    // 移動入力がされているなら処理を抜ける
                    if (mov != 0) break;

                    /* 上下の入力状態を送る */
                    if (GetHoldPress(E_KB.UP)) mov = 1;
                    if (GetHoldPress(E_KB.DOWN)) mov = -1;

                    break;
                }
            case E_COORDINATE.HORIZONTAL:
                {
                    /* 左右の入力状態を送る */
                    if(GetHoldPress(E_KB.A)) mov = -1;
                    if (GetHoldPress(E_KB.D)) mov = 1;

                    // 移動入力がされているなら処理を抜ける
                    if (mov != 0) break;

                    /* 左右の入力状態を送る */
                    if (GetHoldPress(E_KB.LEFT)) mov = -1;
                    if (GetHoldPress(E_KB.RIGHT)) mov = 1;

                    break;
                }
        }

        return mov;
    }

    /* 指定されたスティックの傾きのどちらかを返す */
    public double GetStickValue(E_DIRECTION _dir, E_COORDINATE _cor)
    {
        // ゲームパッドが接続されていなければ処理を抜ける
        if (Gamepad.current == null) return 0.0f;

        switch (_dir)
        {
            case E_DIRECTION.LEFT:
                {
                    switch(_cor)
                    {
                        case E_COORDINATE.VERTICAL:     return Gamepad.current.leftStick.ReadValue().y;
                        case E_COORDINATE.HORIZONTAL:   return Gamepad.current.leftStick.ReadValue().x;
                    }

                    break;
                }
            case E_DIRECTION.RIGHT:
                {
                    switch(_cor)
                    {
                        case E_COORDINATE.VERTICAL:     return Gamepad.current.rightStick.ReadValue().y;
                        case E_COORDINATE.HORIZONTAL:   return Gamepad.current.rightStick.ReadValue().x;
                    }

                    break;
                }
        }

        return 0.0f;
    }

    /* 指定されたスティックの傾きをすべて返す */
    public Vector2 GetStickValue(E_DIRECTION _dir)
    {
        // ゲームパッドが接続されていなければ処理を抜ける
        if (Gamepad.current == null) return new Vector2(0.0f, 0.0f);

        switch (_dir)
        {
            case E_DIRECTION.LEFT: return Gamepad.current.leftStick.ReadValue();
            case E_DIRECTION.RIGHT: return Gamepad.current.rightStick.ReadValue();
        }

        return new Vector2(0.0f, 0.0f);
    }

    /* 指定されたトリガーが押されたかを返す */
    public bool GetTriggerSqueeze(E_DIRECTION _dir, float _deadzone = 0.0f)
    {
        // ゲームパッドが接続されていなければ処理を抜ける
        if (Gamepad.current == null) return false;

        switch (_dir)
        {
            case E_DIRECTION.LEFT: if (Gamepad.current.leftTrigger.ReadValue() > _deadzone) return true; break;
            case E_DIRECTION.RIGHT: if (Gamepad.current.rightTrigger.ReadValue() > _deadzone) return true; break;
        }

        return false;
    }

    /* 指定されたトリガーの情報を返す */
    public double GetTriggerValue(E_DIRECTION _dir)
    {
        // ゲームパッドが接続されていなければ処理を抜ける
        if (Gamepad.current == null) return 0.0f;

        switch (_dir)
        {
            case E_DIRECTION.LEFT:  return Gamepad.current.leftTrigger.ReadValue();
            case E_DIRECTION.RIGHT: return Gamepad.current.rightTrigger.ReadValue();
        }

        return 0.0f;
    }

    /* 入力タイプを設定して状態を返す（ゲームパッド） */
    public bool GetVariousInput(E_TYPE _type, E_GP _gp)
    {
        // ゲームパッドが接続されていなければ処理を抜ける
        if (Gamepad.current == null) return false;

        switch (_type)
        {
            case E_TYPE.PRESSED: return GetPressed(_gp);
            case E_TYPE.RELEASED: return GetReleased(_gp);
            case E_TYPE.HOLDPRESS: return GetHoldPress(_gp);
        }

        return false;
    }

    /* 入力タイプを設定して状態を返す（キーボード） */
    public bool GetVariousInput(E_TYPE _type, E_KB _kb)
    {
        switch (_type)
        {
            case E_TYPE.PRESSED: return GetPressed(_kb);
            case E_TYPE.RELEASED: return GetReleased(_kb);
            case E_TYPE.HOLDPRESS: return GetHoldPress(_kb);
        }

        return false;
    }

    /* 押された瞬間の状態を返す（ゲームパッド） */
    public bool GetPressed(E_GP _gp)
    {
        // ゲームパッドが接続されていなければ処理を抜ける
        if (Gamepad.current == null) return false;

        switch (_gp)
        {
            case E_GP.A: if (Gamepad.current.buttonSouth.wasPressedThisFrame) return true; break;
            case E_GP.B: if (Gamepad.current.buttonEast.wasPressedThisFrame) return true; break;
            case E_GP.X: if (Gamepad.current.buttonWest.wasPressedThisFrame) return true; break;
            case E_GP.Y: if (Gamepad.current.buttonNorth.wasPressedThisFrame) return true; break;
            case E_GP.UP: if (Gamepad.current.dpad.up.wasPressedThisFrame) return true; break;
            case E_GP.DOWN: if (Gamepad.current.dpad.down.wasPressedThisFrame) return true; break;
            case E_GP.LEFT: if (Gamepad.current.dpad.left.wasPressedThisFrame) return true; break;
            case E_GP.RIGHT: if (Gamepad.current.dpad.right.wasPressedThisFrame) return true; break;
            case E_GP.LB: if (Gamepad.current.leftShoulder.wasPressedThisFrame) return true; break;
            case E_GP.RB: if (Gamepad.current.rightShoulder.wasPressedThisFrame) return true; break;
            case E_GP.START: if (Gamepad.current.startButton.wasPressedThisFrame) return true; break;
            case E_GP.SELECT: if (Gamepad.current.selectButton.wasPressedThisFrame) return true; break;
            case E_GP.LSTICK: if (Gamepad.current.leftStickButton.wasPressedThisFrame) return true; break;
            case E_GP.RSTICK: if (Gamepad.current.rightStickButton.wasPressedThisFrame) return true; break;
        }

        return false;
    }

    /* 押された瞬間の状態を返す（キーボード） */
    public bool GetPressed(E_KB _kb)
    {
        switch (_kb)
        {
            case E_KB.A: if (Keyboard.current.aKey.wasPressedThisFrame) return true; break;
            case E_KB.B: if (Keyboard.current.bKey.wasPressedThisFrame) return true; break;
            case E_KB.C: if (Keyboard.current.cKey.wasPressedThisFrame) return true; break;
            case E_KB.D: if (Keyboard.current.dKey.wasPressedThisFrame) return true; break;
            case E_KB.E: if (Keyboard.current.eKey.wasPressedThisFrame) return true; break;
            case E_KB.F: if (Keyboard.current.fKey.wasPressedThisFrame) return true; break;
            case E_KB.G: if (Keyboard.current.gKey.wasPressedThisFrame) return true; break;
            case E_KB.H: if (Keyboard.current.hKey.wasPressedThisFrame) return true; break;
            case E_KB.I: if (Keyboard.current.iKey.wasPressedThisFrame) return true; break;
            case E_KB.J: if (Keyboard.current.jKey.wasPressedThisFrame) return true; break;
            case E_KB.K: if (Keyboard.current.kKey.wasPressedThisFrame) return true; break;
            case E_KB.L: if (Keyboard.current.lKey.wasPressedThisFrame) return true; break;
            case E_KB.M: if (Keyboard.current.mKey.wasPressedThisFrame) return true; break;
            case E_KB.N: if (Keyboard.current.nKey.wasPressedThisFrame) return true; break;
            case E_KB.O: if (Keyboard.current.oKey.wasPressedThisFrame) return true; break;
            case E_KB.P: if (Keyboard.current.pKey.wasPressedThisFrame) return true; break;
            case E_KB.Q: if (Keyboard.current.qKey.wasPressedThisFrame) return true; break;
            case E_KB.R: if (Keyboard.current.rKey.wasPressedThisFrame) return true; break;
            case E_KB.S: if (Keyboard.current.sKey.wasPressedThisFrame) return true; break;
            case E_KB.T: if (Keyboard.current.tKey.wasPressedThisFrame) return true; break;
            case E_KB.U: if (Keyboard.current.uKey.wasPressedThisFrame) return true; break;
            case E_KB.V: if (Keyboard.current.vKey.wasPressedThisFrame) return true; break;
            case E_KB.W: if (Keyboard.current.wKey.wasPressedThisFrame) return true; break;
            case E_KB.X: if (Keyboard.current.xKey.wasPressedThisFrame) return true; break;
            case E_KB.Y: if (Keyboard.current.yKey.wasPressedThisFrame) return true; break;
            case E_KB.Z: if (Keyboard.current.zKey.wasPressedThisFrame) return true; break;
            case E_KB.UP: if (Keyboard.current.upArrowKey.wasPressedThisFrame) return true; break;
            case E_KB.DOWN: if (Keyboard.current.downArrowKey.wasPressedThisFrame) return true; break;
            case E_KB.LEFT: if (Keyboard.current.leftArrowKey.wasPressedThisFrame) return true; break;
            case E_KB.RIGHT: if (Keyboard.current.rightArrowKey.wasPressedThisFrame) return true; break;
            case E_KB.L_SHIFT: if (Keyboard.current.leftShiftKey.wasPressedThisFrame) return true; break;
            case E_KB.R_SHIFT: if (Keyboard.current.rightShiftKey.wasPressedThisFrame) return true; break;
            case E_KB.SPACE: if (Keyboard.current.spaceKey.wasPressedThisFrame) return true; break;
            case E_KB.ENTER: if (Keyboard.current.enterKey.wasPressedThisFrame) return true; break;
            case E_KB.ESCAPE: if (Keyboard.current.escapeKey.wasPressedThisFrame) return true; break;
        }

        return false;
    }

    /* 離された瞬間の状態を返す（ゲームパッド） */
    public bool GetReleased(E_GP _gp)
    {
        // ゲームパッドが接続されていなければ処理を抜ける
        if (Gamepad.current == null) return false;

        switch (_gp)
        {
            case E_GP.A: if (Gamepad.current.buttonSouth.wasReleasedThisFrame) return true; break;
            case E_GP.B: if (Gamepad.current.buttonEast.wasReleasedThisFrame) return true; break;
            case E_GP.X: if (Gamepad.current.buttonWest.wasReleasedThisFrame) return true; break;
            case E_GP.Y: if (Gamepad.current.buttonNorth.wasReleasedThisFrame) return true; break;
            case E_GP.UP: if (Gamepad.current.dpad.up.wasReleasedThisFrame) return true; break;
            case E_GP.DOWN: if (Gamepad.current.dpad.down.wasReleasedThisFrame) return true; break;
            case E_GP.LEFT: if (Gamepad.current.dpad.left.wasReleasedThisFrame) return true; break;
            case E_GP.RIGHT: if (Gamepad.current.dpad.right.wasReleasedThisFrame) return true; break;
            case E_GP.LB: if (Gamepad.current.leftShoulder.wasReleasedThisFrame) return true; break;
            case E_GP.RB: if (Gamepad.current.rightShoulder.wasReleasedThisFrame) return true; break;
            case E_GP.START: if (Gamepad.current.startButton.wasReleasedThisFrame) return true; break;
            case E_GP.SELECT: if (Gamepad.current.selectButton.wasReleasedThisFrame) return true; break;
            case E_GP.LSTICK: if (Gamepad.current.leftStickButton.wasReleasedThisFrame) return true; break;
            case E_GP.RSTICK: if (Gamepad.current.rightStickButton.wasReleasedThisFrame) return true; break;
        }

        return false;
    }

    /* 離された瞬間の状態を返す（キーボード） */
    public bool GetReleased(E_KB _kb)
    {
        switch (_kb)
        {
            case E_KB.A: if (Keyboard.current.aKey.wasReleasedThisFrame) return true; break;
            case E_KB.B: if (Keyboard.current.bKey.wasReleasedThisFrame) return true; break;
            case E_KB.C: if (Keyboard.current.cKey.wasReleasedThisFrame) return true; break;
            case E_KB.D: if (Keyboard.current.dKey.wasReleasedThisFrame) return true; break;
            case E_KB.E: if (Keyboard.current.eKey.wasReleasedThisFrame) return true; break;
            case E_KB.F: if (Keyboard.current.fKey.wasReleasedThisFrame) return true; break;
            case E_KB.G: if (Keyboard.current.gKey.wasReleasedThisFrame) return true; break;
            case E_KB.H: if (Keyboard.current.hKey.wasReleasedThisFrame) return true; break;
            case E_KB.I: if (Keyboard.current.iKey.wasReleasedThisFrame) return true; break;
            case E_KB.J: if (Keyboard.current.jKey.wasReleasedThisFrame) return true; break;
            case E_KB.K: if (Keyboard.current.kKey.wasReleasedThisFrame) return true; break;
            case E_KB.L: if (Keyboard.current.lKey.wasReleasedThisFrame) return true; break;
            case E_KB.M: if (Keyboard.current.mKey.wasReleasedThisFrame) return true; break;
            case E_KB.N: if (Keyboard.current.nKey.wasReleasedThisFrame) return true; break;
            case E_KB.O: if (Keyboard.current.oKey.wasReleasedThisFrame) return true; break;
            case E_KB.P: if (Keyboard.current.pKey.wasReleasedThisFrame) return true; break;
            case E_KB.Q: if (Keyboard.current.qKey.wasReleasedThisFrame) return true; break;
            case E_KB.R: if (Keyboard.current.rKey.wasReleasedThisFrame) return true; break;
            case E_KB.S: if (Keyboard.current.sKey.wasReleasedThisFrame) return true; break;
            case E_KB.T: if (Keyboard.current.tKey.wasReleasedThisFrame) return true; break;
            case E_KB.U: if (Keyboard.current.uKey.wasReleasedThisFrame) return true; break;
            case E_KB.V: if (Keyboard.current.vKey.wasReleasedThisFrame) return true; break;
            case E_KB.W: if (Keyboard.current.wKey.wasReleasedThisFrame) return true; break;
            case E_KB.X: if (Keyboard.current.xKey.wasReleasedThisFrame) return true; break;
            case E_KB.Y: if (Keyboard.current.yKey.wasReleasedThisFrame) return true; break;
            case E_KB.Z: if (Keyboard.current.zKey.wasReleasedThisFrame) return true; break;
            case E_KB.UP: if (Keyboard.current.upArrowKey.wasReleasedThisFrame) return true; break;
            case E_KB.DOWN: if (Keyboard.current.downArrowKey.wasReleasedThisFrame) return true; break;
            case E_KB.LEFT: if (Keyboard.current.leftArrowKey.wasReleasedThisFrame) return true; break;
            case E_KB.RIGHT: if (Keyboard.current.rightArrowKey.wasReleasedThisFrame) return true; break;
            case E_KB.L_SHIFT: if (Keyboard.current.leftShiftKey.wasReleasedThisFrame) return true; break;
            case E_KB.R_SHIFT: if (Keyboard.current.rightShiftKey.wasReleasedThisFrame) return true; break;
            case E_KB.SPACE: if (Keyboard.current.spaceKey.wasReleasedThisFrame) return true; break;
            case E_KB.ENTER: if (Keyboard.current.enterKey.wasReleasedThisFrame) return true; break;
            case E_KB.ESCAPE: if (Keyboard.current.escapeKey.wasReleasedThisFrame) return true; break;
        }

        return false;
    }

    /* 押されている状態を返す（ゲームパッド） */
    public bool GetHoldPress(E_GP _gp)
    {
        // ゲームパッドが接続されていなければ処理を抜ける
        if (Gamepad.current == null) return false;

        switch (_gp)
        {
            case E_GP.A: if (Gamepad.current.buttonSouth.isPressed) return true; break;
            case E_GP.B: if (Gamepad.current.buttonEast.isPressed) return true; break;
            case E_GP.X: if (Gamepad.current.buttonWest.isPressed) return true; break;
            case E_GP.Y: if (Gamepad.current.buttonNorth.isPressed) return true; break;
            case E_GP.UP: if (Gamepad.current.dpad.up.isPressed) return true; break;
            case E_GP.DOWN: if (Gamepad.current.dpad.down.isPressed) return true; break;
            case E_GP.LEFT: if (Gamepad.current.dpad.left.isPressed) return true; break;
            case E_GP.RIGHT: if (Gamepad.current.dpad.right.isPressed) return true; break;
            case E_GP.LB: if (Gamepad.current.leftShoulder.isPressed) return true; break;
            case E_GP.RB: if (Gamepad.current.rightShoulder.isPressed) return true; break;
            case E_GP.START: if (Gamepad.current.startButton.isPressed) return true; break;
            case E_GP.SELECT: if (Gamepad.current.selectButton.isPressed) return true; break;
            case E_GP.LSTICK: if (Gamepad.current.leftStickButton.isPressed) return true; break;
            case E_GP.RSTICK: if (Gamepad.current.rightStickButton.isPressed) return true; break;
        }

        return false;
    }

    /* 押されている状態を返す（キーボード） */
    public bool GetHoldPress(E_KB _kb)
    {
        switch (_kb)
        {
            case E_KB.A: if (Keyboard.current.aKey.isPressed) return true; break;
            case E_KB.B: if (Keyboard.current.bKey.isPressed) return true; break;
            case E_KB.C: if (Keyboard.current.cKey.isPressed) return true; break;
            case E_KB.D: if (Keyboard.current.dKey.isPressed) return true; break;
            case E_KB.E: if (Keyboard.current.eKey.isPressed) return true; break;
            case E_KB.F: if (Keyboard.current.fKey.isPressed) return true; break;
            case E_KB.G: if (Keyboard.current.gKey.isPressed) return true; break;
            case E_KB.H: if (Keyboard.current.hKey.isPressed) return true; break;
            case E_KB.I: if (Keyboard.current.iKey.isPressed) return true; break;
            case E_KB.J: if (Keyboard.current.jKey.isPressed) return true; break;
            case E_KB.K: if (Keyboard.current.kKey.isPressed) return true; break;
            case E_KB.L: if (Keyboard.current.lKey.isPressed) return true; break;
            case E_KB.M: if (Keyboard.current.mKey.isPressed) return true; break;
            case E_KB.N: if (Keyboard.current.nKey.isPressed) return true; break;
            case E_KB.O: if (Keyboard.current.oKey.isPressed) return true; break;
            case E_KB.P: if (Keyboard.current.pKey.isPressed) return true; break;
            case E_KB.Q: if (Keyboard.current.qKey.isPressed) return true; break;
            case E_KB.R: if (Keyboard.current.rKey.isPressed) return true; break;
            case E_KB.S: if (Keyboard.current.sKey.isPressed) return true; break;
            case E_KB.T: if (Keyboard.current.tKey.isPressed) return true; break;
            case E_KB.U: if (Keyboard.current.uKey.isPressed) return true; break;
            case E_KB.V: if (Keyboard.current.vKey.isPressed) return true; break;
            case E_KB.W: if (Keyboard.current.wKey.isPressed) return true; break;
            case E_KB.X: if (Keyboard.current.xKey.isPressed) return true; break;
            case E_KB.Y: if (Keyboard.current.yKey.isPressed) return true; break;
            case E_KB.Z: if (Keyboard.current.zKey.isPressed) return true; break;
            case E_KB.UP: if (Keyboard.current.upArrowKey.isPressed) return true; break;
            case E_KB.DOWN: if (Keyboard.current.downArrowKey.isPressed) return true; break;
            case E_KB.LEFT: if (Keyboard.current.leftArrowKey.isPressed) return true; break;
            case E_KB.RIGHT: if (Keyboard.current.rightArrowKey.isPressed) return true; break;
            case E_KB.L_SHIFT: if (Keyboard.current.leftShiftKey.isPressed) return true; break;
            case E_KB.R_SHIFT: if (Keyboard.current.rightShiftKey.isPressed) return true; break;
            case E_KB.SPACE: if (Keyboard.current.spaceKey.isPressed) return true; break;
            case E_KB.ENTER: if (Keyboard.current.enterKey.isPressed) return true; break;
            case E_KB.ESCAPE: if (Keyboard.current.escapeKey.isPressed) return true; break;
        }

        return false;
    }
}
