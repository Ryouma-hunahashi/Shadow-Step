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
    [Header("スティックの入力タイプ")]
    [SerializeField] private STICK_MOVE_TYPE stickType;
    [Header("入力の反転")]
    [SerializeField] private bool reverse;
    [Tooltip("入力のクールタイム")]
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
        // 値を保存先から取得
        //coolTime = EditorPrefs.GetFloat("coolTime", 0f);
        //stickType = (STICK_MOVE_TYPE)EditorPrefs.GetInt("stickType"+ thisNum.ToString(), 0);
        //reverse = EditorPrefs.GetBool("reverse" + thisNum.ToString(), false);
        //EditorGUI.BeginChangeCheck();
    }

    public void Update()
    {
        if(nowTime == Time.time) {Debug.Log("二回目の入力故弾くぜ"); return; }
        float inputStick = stickType == STICK_MOVE_TYPE.STICK_HORIZONTAL ? Input.GetAxisRaw("Horizontal") : Input.GetAxisRaw("Vertical");
        // 入力の正負を保存
        float inputSign = Mathf.Sign(inputStick);
        // 入力値が仮のデッドライン以上の時
        if (Mathf.Abs(inputStick) >= 0.4f)
        {
            // 入力の正負がログと異なる、またはクールタイム中でないとき
            if (inputSign != inputSignLog || !nowCool)
            {
                // 入力方向を移動方向に設定
                moveNum = !reverse ? (int)inputSign : -(int)inputSign;
                // クールタイム開始
                nowCool = true;
                coolElapsed = 0.0f;
            }
            else
            {
                // 移動方向を0に
                moveNum = 0;
            }
            // スティックの入力方向を保存
            inputSignLog = Mathf.Sign(inputStick);
        }
        else
        {
            // 移動方向を0に
            moveNum = 0;
        }
        // クールタイム中であれば
        if(nowCool)
        {
            // 経過時間加算
            coolElapsed += Time.deltaTime;
            // クールタイムを超えれば切る
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
