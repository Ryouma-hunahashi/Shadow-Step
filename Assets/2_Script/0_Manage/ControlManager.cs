using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

/* ------------------------------
 * 
 * �쐬���F24/03/18
 * �X�V���F24/03/18
 * �쐬�ҁF�{���q��
 * 
 * 2024/03/18
 * �f�b�h�]�[����p�����X�e�B�b�N�l��
 * Int�^�ő���֐����쐬���܂���
 * 
 * --------------------------- */

public class ControlManager : MonoBehaviour
{
    [SerializeField] private bool isDebug = false;

    /* �񋓑̐錾 */
    public enum E_TYPE
    {
        PRESSED,    // ������
        RELEASED,   // ������
        HOLDPRESS,  // �����Ă���
    }

    // �Q�[���p�b�h�{�^���̗�
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

    // �L�[�{�[�h�̗�
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

    // ���E���̗�
    public enum E_DIRECTION
    {
        LEFT,
        RIGHT,
    }

    // �������W�n
    public enum E_COORDINATE
    {
        VERTICAL,   // ����
        HORIZONTAL, // ����
    }

    private void Update()
    {
        /* �f�o�b�O���Ȃ��Ȃ珈���𔲂��� */
        if (!isDebug) return;

        Debug.Log("�Е�������ƂłƂ��[�F��Hori" + GetStickIntegerValue(E_DIRECTION.LEFT, E_COORDINATE.VERTICAL));
        Debug.Log("�Е�������ƂłƂ��[�F��Vart" + GetStickIntegerValue(E_DIRECTION.LEFT, E_COORDINATE.HORIZONTAL));
        Debug.Log("�Е�������ƂłƂ��[�F�EHori" + GetStickIntegerValue(E_DIRECTION.RIGHT, E_COORDINATE.VERTICAL));
        Debug.Log("�Е�������ƂłƂ��[�F�EVart" + GetStickIntegerValue(E_DIRECTION.RIGHT, E_COORDINATE.HORIZONTAL));

        Debug.Log("�Е��Ƃ��[�F��Hori" + GetStickValue(E_DIRECTION.LEFT, E_COORDINATE.VERTICAL));
        Debug.Log("�Е��Ƃ��[�F��Vart" + GetStickValue(E_DIRECTION.LEFT, E_COORDINATE.HORIZONTAL));
        Debug.Log("�Е��Ƃ��[�F�EHori" + GetStickValue(E_DIRECTION.RIGHT, E_COORDINATE.VERTICAL));
        Debug.Log("�Е��Ƃ��[�F�EVart" + GetStickValue(E_DIRECTION.RIGHT, E_COORDINATE.HORIZONTAL));

        Debug.Log("�Ђ���@�Ƃ肪�[�I" + GetTriggerValue(E_DIRECTION.LEFT));
        Debug.Log("�݂��@�@�Ƃ肪�[�I" + GetTriggerValue(E_DIRECTION.RIGHT));

        Debug.Log("��������[" + GetStickValue(E_DIRECTION.LEFT));
        Debug.Log("��������[" + GetStickValue(E_DIRECTION.RIGHT));
    }

    public bool GetConnect()
    {
        if(Gamepad.current == null) return false;

        return true;
    }

    /* �w�肳�ꂽ�X�e�B�b�N�̌X���𐮐��ŕԂ� */
    public int GetStickIntegerValue(E_DIRECTION _dir,E_COORDINATE _cor, float _deadzone = 0.0f)
    {
        // �Q�[���p�b�h���ڑ�����Ă��Ȃ���Ώ����𔲂���
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

    /* �w�肳�ꂽ����Е��̃L�[���͂�Ԃ� */
    public int GetWASD_IntegerValue(E_COORDINATE _cor)
    {
        int mov = 0;

        switch(_cor)
        {
            case E_COORDINATE.VERTICAL:
                {
                    /* �㉺�̓��͏�Ԃ𑗂� */
                    if(GetHoldPress(E_KB.W)) mov = 1;
                    if(GetHoldPress(E_KB.S)) mov = -1;

                    // �ړ����͂�����Ă���Ȃ珈���𔲂���
                    if (mov != 0) break;

                    /* �㉺�̓��͏�Ԃ𑗂� */
                    if (GetHoldPress(E_KB.UP)) mov = 1;
                    if (GetHoldPress(E_KB.DOWN)) mov = -1;

                    break;
                }
            case E_COORDINATE.HORIZONTAL:
                {
                    /* ���E�̓��͏�Ԃ𑗂� */
                    if(GetHoldPress(E_KB.A)) mov = -1;
                    if (GetHoldPress(E_KB.D)) mov = 1;

                    // �ړ����͂�����Ă���Ȃ珈���𔲂���
                    if (mov != 0) break;

                    /* ���E�̓��͏�Ԃ𑗂� */
                    if (GetHoldPress(E_KB.LEFT)) mov = -1;
                    if (GetHoldPress(E_KB.RIGHT)) mov = 1;

                    break;
                }
        }

        return mov;
    }

    /* �w�肳�ꂽ�X�e�B�b�N�̌X���̂ǂ��炩��Ԃ� */
    public double GetStickValue(E_DIRECTION _dir, E_COORDINATE _cor)
    {
        // �Q�[���p�b�h���ڑ�����Ă��Ȃ���Ώ����𔲂���
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

    /* �w�肳�ꂽ�X�e�B�b�N�̌X�������ׂĕԂ� */
    public Vector2 GetStickValue(E_DIRECTION _dir)
    {
        // �Q�[���p�b�h���ڑ�����Ă��Ȃ���Ώ����𔲂���
        if (Gamepad.current == null) return new Vector2(0.0f, 0.0f);

        switch (_dir)
        {
            case E_DIRECTION.LEFT: return Gamepad.current.leftStick.ReadValue();
            case E_DIRECTION.RIGHT: return Gamepad.current.rightStick.ReadValue();
        }

        return new Vector2(0.0f, 0.0f);
    }

    /* �w�肳�ꂽ�g���K�[�������ꂽ����Ԃ� */
    public bool GetTriggerSqueeze(E_DIRECTION _dir, float _deadzone = 0.0f)
    {
        // �Q�[���p�b�h���ڑ�����Ă��Ȃ���Ώ����𔲂���
        if (Gamepad.current == null) return false;

        switch (_dir)
        {
            case E_DIRECTION.LEFT: if (Gamepad.current.leftTrigger.ReadValue() > _deadzone) return true; break;
            case E_DIRECTION.RIGHT: if (Gamepad.current.rightTrigger.ReadValue() > _deadzone) return true; break;
        }

        return false;
    }

    /* �w�肳�ꂽ�g���K�[�̏���Ԃ� */
    public double GetTriggerValue(E_DIRECTION _dir)
    {
        // �Q�[���p�b�h���ڑ�����Ă��Ȃ���Ώ����𔲂���
        if (Gamepad.current == null) return 0.0f;

        switch (_dir)
        {
            case E_DIRECTION.LEFT:  return Gamepad.current.leftTrigger.ReadValue();
            case E_DIRECTION.RIGHT: return Gamepad.current.rightTrigger.ReadValue();
        }

        return 0.0f;
    }

    /* ���̓^�C�v��ݒ肵�ď�Ԃ�Ԃ��i�Q�[���p�b�h�j */
    public bool GetVariousInput(E_TYPE _type, E_GP _gp)
    {
        // �Q�[���p�b�h���ڑ�����Ă��Ȃ���Ώ����𔲂���
        if (Gamepad.current == null) return false;

        switch (_type)
        {
            case E_TYPE.PRESSED: return GetPressed(_gp);
            case E_TYPE.RELEASED: return GetReleased(_gp);
            case E_TYPE.HOLDPRESS: return GetHoldPress(_gp);
        }

        return false;
    }

    /* ���̓^�C�v��ݒ肵�ď�Ԃ�Ԃ��i�L�[�{�[�h�j */
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

    /* �����ꂽ�u�Ԃ̏�Ԃ�Ԃ��i�Q�[���p�b�h�j */
    public bool GetPressed(E_GP _gp)
    {
        // �Q�[���p�b�h���ڑ�����Ă��Ȃ���Ώ����𔲂���
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

    /* �����ꂽ�u�Ԃ̏�Ԃ�Ԃ��i�L�[�{�[�h�j */
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

    /* �����ꂽ�u�Ԃ̏�Ԃ�Ԃ��i�Q�[���p�b�h�j */
    public bool GetReleased(E_GP _gp)
    {
        // �Q�[���p�b�h���ڑ�����Ă��Ȃ���Ώ����𔲂���
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

    /* �����ꂽ�u�Ԃ̏�Ԃ�Ԃ��i�L�[�{�[�h�j */
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

    /* ������Ă����Ԃ�Ԃ��i�Q�[���p�b�h�j */
    public bool GetHoldPress(E_GP _gp)
    {
        // �Q�[���p�b�h���ڑ�����Ă��Ȃ���Ώ����𔲂���
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

    /* ������Ă����Ԃ�Ԃ��i�L�[�{�[�h�j */
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
