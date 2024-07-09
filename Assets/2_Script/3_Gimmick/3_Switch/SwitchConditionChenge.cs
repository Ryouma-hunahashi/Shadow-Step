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

    

    private VariousSwitches varSwich;     // �X�C�b�`�̃X�N���v�g
    [Header("�X�C�b�`�̃^�C�v")]
    [Tooltip("TRIGGER�F����������\n" +
             "STAY   �F�������Ă����\n" +
             "EXIT   �F���ꂽ��\n" +
             "TIMER  �F���Ԃ��o������")]
    [SerializeField] private E_SWITCH_TYPE type = E_SWITCH_TYPE.TRIGGER;
    
    [Header("�X�C�b�`���I���ɂ���I�u�W�F�N�g")]
    [SerializeField] private E_ACTIVE_PARSON[] activeParson = { E_ACTIVE_PARSON.PLAYER };


    [Header("�X�C�b�`�̏������")]
    [SerializeField] private E_DEFAULT_STATUS defaultStatus = E_DEFAULT_STATUS.OFF;
    private bool defaultSwitch = false;

    [Header("TIMER��p")]
    [Header("�������ԁi�P�ʁF�b�j")]
    [SerializeField, Min(0)] private int timer = 1;
    private int nowTime = 0;

    [Header("�X�C�b�`�̋�������(Stay�̏ꍇ�͎g�p���Ȃ��ł�������)")]
    [Tooltip("ONtoOFF�FON����OFF�̂ݕύX��\n" +
             "OFFtoON�FOFF����ON�̂ݕύX��\n" +
             "none   �F�����邽�тɐ؂�ւ�")]
    [SerializeField] private E_SWITCH_RULE rule = E_SWITCH_RULE.none;


    [Header("�X�C�b�`�̍쓮��")]
    [Tooltip("LIMIT  �F���E����\n" +
             "UNLIMIT�F������")]
    [SerializeField] private E_SWITCH_TIMES switchCounts = E_SWITCH_TIMES.UNLIMIT;
    [Tooltip("�쓮�񐔂�[ LIMIT ]�̏ꍇ�A�񐔂��w��")]
    [SerializeField, Min(1)] private byte limitCounts = 1;


    [Header("�X�C�b�`�̃N�[���^�C���i�P�ʁF�t���[���j")]
    [SerializeField] private E_DEFAULT_STATUS coolTimeCheck = E_DEFAULT_STATUS.ON;
    [SerializeField] private float coolTime = 30;
    private byte nowSwitchCount = 0;        // ���݂̃X�C�b�`�쓮��
    private byte nowCoolTime = 0;
    private bool nowCool = false;


    //private float 


    void Start()
    {
        // ���̃I�u�W�F�N�g���̃X�C�b�`���i�[
        varSwich = GetComponent<VariousSwitches>();
        
        // ���E�l��0�ȉ��̎���1�ɌŒ�B(�o�O��U�炩������)
        if(limitCounts <= 0)
        {
            limitCounts = 1;
        }

        // Stay�̎��̓N�[���^�C���𔭐������Ȃ��悤�ɂ���B
        if(type == E_SWITCH_TYPE.STAY)
        {
            coolTimeCheck = E_DEFAULT_STATUS.OFF;
        }

        // �����̃X�C�b�`��Ԃ��i�[
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
            // �񐔐������Ȃ����A�񐔐����Ɏ����Ă��Ȃ��Ƃ�
            if (switchCounts == E_SWITCH_TIMES.UNLIMIT || nowSwitchCount < limitCounts)
            {
                // �����������A�������Ă���Ԃ̃X�C�b�`��؂�ւ���B
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
            // �񐔐������Ȃ����A�񐔐����Ɏ����Ă��Ȃ��Ƃ�
            if (switchCounts == E_SWITCH_TIMES.UNLIMIT || nowSwitchCount <= limitCounts)
            {
                // �������Ă���ԁA���ꂽ���̃X�C�b�`��؂�ւ���B
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
        // �񐔐������Ȃ����A�񐔐����Ɏ����Ă��Ȃ��Ƃ�
        if (switchCounts == E_SWITCH_TIMES.UNLIMIT || nowSwitchCount < limitCounts)
        {
            // �������Ă���ԁA���ꂽ���̃X�C�b�`��؂�ւ���B
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
    /// �X�C�b�`��؂�ւ�����Ώۂɉ����āA�؂�ւ��邩�̔��ʂ��s��
    /// </summary>
    /// <param name="other"> �Ԃ������I�u�W�F�N�g��Collider </param>
    private void ActiveCheck(Collider other)
    {
        // �쓮��������Ώۂ̐��J��Ԃ�
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
    /// �X�C�b�`��؂�ւ��鏈��
    /// </summary>
    private void switchChange()
    {
        
        switch (rule)
        {
            case E_SWITCH_RULE.OnToOff:
                if (varSwich.nowSwitchStatus)
                {
                    varSwich.nowSwitchStatus = false;
                    // �؂�ւ����E�����݂���΁A�؂�ւ��񐔂����Z
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
                    // �؂�ւ����E�����݂���΁A�؂�ւ��񐔂����Z
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
                // switchStatus���t�]������
                if (varSwich.nowSwitchStatus)
                {
                    varSwich.nowSwitchStatus = false;
                    
                }
                else
                {
                    varSwich.nowSwitchStatus = true;
                }
                // �؂�ւ����E�����݂���΁A�؂�ւ��񐔂����Z
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
