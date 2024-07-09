using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class SwitchConditionChenge : MonoBehaviour
{
    private enum E_SWITCH_TYPE
    { 
        TRIGGER,
        STAY,
        EXIT,
        TIMER,
    }

    private enum E_ACTIVE_PARSON
    {
        PLAYER,
        ENEMY,
    }

    private enum E_DEFAULT_STATUS
    {
        ON,
        OFF,
    }

    private enum E_SWITCH_RULE
    {
        OnToOff,
        OffToOn,
        none,
    }

    private enum E_SWITCH_TIMES
    {
        LIMIT,
        UNLIMIT,
    }

    

    private VariousSwitches varSwich;     // スイッチのスクリプト
    [Header("スイッチのタイプ")]
    [Tooltip("TRIGGER：当たった時\n" +
             "STAY   ：当たっている間\n" +
             "EXIT   ：離れた時\n" +
             "TIMER  ：時間が経った時")]
    [SerializeField] private E_SWITCH_TYPE type = E_SWITCH_TYPE.TRIGGER;
    
    [Header("スイッチをオンにするオブジェクト")]
    [SerializeField] private E_ACTIVE_PARSON[] activeParson = { E_ACTIVE_PARSON.PLAYER };


    [Header("スイッチの初期状態")]
    [SerializeField] private E_DEFAULT_STATUS defaultStatus = E_DEFAULT_STATUS.OFF;
    private bool defaultSwitch = false;

    [Header("TIMER専用")]
    [Header("制限時間（単位：秒）")]
    [SerializeField, Min(0)] private int timer = 1;
    private int nowTime = 0;

    [Header("スイッチの挙動制限(Stayの場合は使用しないでください)")]
    [Tooltip("ONtoOFF：ONからOFFのみ変更可\n" +
             "OFFtoON：OFFからONのみ変更可\n" +
             "none   ：当たるたびに切り替え")]
    [SerializeField] private E_SWITCH_RULE rule = E_SWITCH_RULE.none;


    [Header("スイッチの作動回数")]
    [Tooltip("LIMIT  ：限界あり\n" +
             "UNLIMIT：無制限")]
    [SerializeField] private E_SWITCH_TIMES switchCounts = E_SWITCH_TIMES.UNLIMIT;
    [Tooltip("作動回数が[ LIMIT ]の場合、回数を指定")]
    [SerializeField, Min(1)] private byte limitCounts = 1;


    [Header("スイッチのクールタイム（単位：フレーム）")]
    [SerializeField] private E_DEFAULT_STATUS coolTimeCheck = E_DEFAULT_STATUS.ON;
    [SerializeField] private float coolTime = 30;
    private byte nowSwitchCount = 0;        // 現在のスイッチ作動回数
    private byte nowCoolTime = 0;
    private bool nowCool = false;


    //private float 


    void Start()
    {
        // このオブジェクト内のスイッチを格納
        varSwich = GetComponent<VariousSwitches>();
        
        // 限界値が0以下の時は1に固定。(バグり散らかすため)
        if(limitCounts <= 0)
        {
            limitCounts = 1;
        }

        // Stayの時はクールタイムを発生させないようにする。
        if(type == E_SWITCH_TYPE.STAY)
        {
            coolTimeCheck = E_DEFAULT_STATUS.OFF;
        }

        // 初期のスイッチ状態を格納
        switch(defaultStatus)
        {
            case E_DEFAULT_STATUS.ON:
                varSwich.nowSwitchStatus = true;
                defaultSwitch = true;
                break;
            case E_DEFAULT_STATUS.OFF:
                varSwich.nowSwitchStatus= false;
                defaultSwitch = false;
                break;
        }
        
    }



    private void FixedUpdate()
    {
        //Debug.Log(nowSwitchCount);
        if(nowCool)
        {
            if(nowCoolTime<coolTime)
            {
                nowCoolTime++;
            }
            else
            {
                nowCoolTime = 0;
                nowCool = false;
            }
        }

        Timer();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!nowCool)
        {
            // 回数制限がないか、回数制限に至っていないとき
            if (switchCounts == E_SWITCH_TIMES.UNLIMIT || nowSwitchCount < limitCounts)
            {
                // 当たった時、当たっている間のスイッチを切り替える。
                switch (type)
                {
                    case E_SWITCH_TYPE.TRIGGER:
                        ActiveCheck(other);
                        break;

                }
            }
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (varSwich.nowSwitchStatus == defaultSwitch)
        {
            // 回数制限がないか、回数制限に至っていないとき
            if (switchCounts == E_SWITCH_TIMES.UNLIMIT || nowSwitchCount <= limitCounts)
            {
                // 当たっている間、離れた時のスイッチを切り替える。
                switch (type)
                {
                    case E_SWITCH_TYPE.STAY:
                        ActiveCheck(other);
                        break;
                    case E_SWITCH_TYPE.TIMER:
                        varSwich.nowSwitchStatus = true;
                        nowTime = 0;
                        break;
                }
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        // 回数制限がないか、回数制限に至っていないとき
        if (switchCounts == E_SWITCH_TIMES.UNLIMIT || nowSwitchCount < limitCounts)
        {
            // 当たっている間、離れた時のスイッチを切り替える。
            switch (type)
            {
                case E_SWITCH_TYPE.STAY:
                    ActiveCheck(other);
                    break;
                case E_SWITCH_TYPE.EXIT:
                    if (!nowCool)
                    {
                        ActiveCheck(other);
                    }
                    break;
            }
        }
    }

    /// <summary>
    /// スイッチを切り替えられる対象に応じて、切り替えるかの判別を行う
    /// </summary>
    /// <param name="other"> ぶつかったオブジェクトのCollider </param>
    private void ActiveCheck(Collider other)
    {
        // 作動させられる対象の数繰り返す
        for (byte i = 0; i < activeParson.Length; i++)
        {
            switch (activeParson[i])
            {
                case E_ACTIVE_PARSON.PLAYER:
                    if(other.CompareTag("Player"))
                    {
                        switchChange();
                    }
                    break;
                case E_ACTIVE_PARSON.ENEMY:
                    if (other.CompareTag("Enemy"))
                    {
                        switchChange();
                    }
                    break;
            }
            
        }
    }

    /// <summary>
    /// スイッチを切り替える処理
    /// </summary>
    private void switchChange()
    {
        
        switch (rule)
        {
            case E_SWITCH_RULE.OnToOff:
                if (varSwich.nowSwitchStatus)
                {
                    varSwich.nowSwitchStatus = false;
                    // 切り替え限界が存在すれば、切り替え回数を加算
                    if (switchCounts == E_SWITCH_TIMES.LIMIT)
                    {
                        AddChangeCount();
                        varSwich.AddFamilyChangeCount();

                    }
                    if(coolTimeCheck == E_DEFAULT_STATUS.ON)
                    {
                        SetCoolTime();
                        varSwich.SetFamilyCoolTime();
                    }
                }
                break;
            case E_SWITCH_RULE.OffToOn:
                if (!varSwich.nowSwitchStatus)
                {
                    varSwich.nowSwitchStatus = true;
                    // 切り替え限界が存在すれば、切り替え回数を加算
                    if (switchCounts == E_SWITCH_TIMES.LIMIT)
                    {
                        AddChangeCount();
                        varSwich.AddFamilyChangeCount();

                    }
                    if (coolTimeCheck == E_DEFAULT_STATUS.ON)
                    {
                        SetCoolTime();
                        varSwich.SetFamilyCoolTime();
                    }
                }
                break;
            case E_SWITCH_RULE.none:
                // switchStatusを逆転させる
                if (varSwich.nowSwitchStatus)
                {
                    varSwich.nowSwitchStatus = false;
                    
                }
                else
                {
                    varSwich.nowSwitchStatus = true;
                }
                // 切り替え限界が存在すれば、切り替え回数を加算
                if (switchCounts == E_SWITCH_TIMES.LIMIT)
                {
                    AddChangeCount();
                    varSwich.AddFamilyChangeCount();

                }
                if (coolTimeCheck == E_DEFAULT_STATUS.ON)
                {
                    SetCoolTime();
                    varSwich.SetFamilyCoolTime();
                }

                break;
        }        
        
    }
    private void Timer()
    {
        if(type != E_SWITCH_TYPE.TIMER)
        {
            return;
        }

        if(nowTime < timer * 60)
        {
            nowTime++;
            return;
        }

        varSwich.nowSwitchStatus = false;

    }
    public void SetCoolTime()
    {
        nowCool = true;
    }
    public void AddChangeCount()
    {
        nowSwitchCount++;
    }

    
}
