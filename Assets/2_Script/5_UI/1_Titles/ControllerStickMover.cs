using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEditor;

[System.Serializable]
public class ControllerStickMover
{
    // Start is called before the first frame update
    public enum STICK_MOVE_TYPE
    {
        STICK_HORIZONTAL,
        STICK_VERTICAL,
    }
    [Header("�X�e�B�b�N�̓��̓^�C�v")]
    [SerializeField] private STICK_MOVE_TYPE stickType;
    [Header("���͂̔��]")]
    [SerializeField] private bool reverse;
    [Tooltip("���͂̃N�[���^�C��")]
    [SerializeField] static public float coolTime = 0.2f;
    private float coolElapsed = 0.0f;
    private bool nowCool = false;
    private float inputSignLog = 1.0f;
    private float nowTime;

    static public int testCnt = 0;
    private int thisNum;


    private int moveNum = 0;


    public void Start()
    {
        thisNum = testCnt;
        testCnt++;
        // �l��ۑ��悩��擾
        //coolTime = EditorPrefs.GetFloat("coolTime", 0f);
        //stickType = (STICK_MOVE_TYPE)EditorPrefs.GetInt("stickType"+ thisNum.ToString(), 0);
        //reverse = EditorPrefs.GetBool("reverse" + thisNum.ToString(), false);
        //EditorGUI.BeginChangeCheck();
    }

    public void Update()
    {
        if(nowTime == Time.time) {Debug.Log("���ڂ̓��͌̒e����"); return; }
        float inputStick = stickType == STICK_MOVE_TYPE.STICK_HORIZONTAL ? Input.GetAxisRaw("Horizontal") : Input.GetAxisRaw("Vertical");
        // ���͂̐�����ۑ�
        float inputSign = Mathf.Sign(inputStick);
        // ���͒l�����̃f�b�h���C���ȏ�̎�
        if (Mathf.Abs(inputStick) >= 0.4f)
        {
            // ���͂̐��������O�ƈقȂ�A�܂��̓N�[���^�C�����łȂ��Ƃ�
            if (inputSign != inputSignLog || !nowCool)
            {
                // ���͕������ړ������ɐݒ�
                moveNum = !reverse ? (int)inputSign : -(int)inputSign;
                // �N�[���^�C���J�n
                nowCool = true;
                coolElapsed = 0.0f;
            }
            else
            {
                // �ړ�������0��
                moveNum = 0;
            }
            // �X�e�B�b�N�̓��͕�����ۑ�
            inputSignLog = Mathf.Sign(inputStick);
        }
        else
        {
            // �ړ�������0��
            moveNum = 0;
        }
        // �N�[���^�C�����ł����
        if(nowCool)
        {
            // �o�ߎ��ԉ��Z
            coolElapsed += Time.deltaTime;
            // �N�[���^�C���𒴂���ΐ؂�
            if(coolElapsed >= coolTime)
            {
                nowCool = false;
                coolElapsed = 0.0f;
            }
        }
        nowTime = Time.time;
        //S_Manager man = new S_Manager();
        //Vector3 pos = transform.position;
        //pos.x += this.GetMoveNum();
        //transform.position = pos;
    }


    public int GetMoveNum() { Update(); return moveNum; }
    public void SetStickType(STICK_MOVE_TYPE _type) { stickType = _type; }
    public void SetReverse(bool _fg) { reverse = _fg; }

}
