using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class VariousSwitches : MonoBehaviour
{
    [Tooltip("�X�C�b�`�̏��")]
    public  bool nowSwitchStatus;   // ���݂̏��
    private bool oldSwitchStatus;   // �O��̏��

    [Header("----- �A�����̐ݒ� -----"), Space(5)]
    [SerializeField] private GameObject myParent; // �e�I�u�W�F�N�g�̎擾
    [SerializeField] private VariousSwitches parentScript;
    [SerializeField] private SwitchConditionChenge parentChenger;
    [SerializeField] private bool parentActive;

    [SerializeField] private List<GameObject> myChildren = new List<GameObject>();  // �q�I�u�W�F�N�g�̎擾
    [SerializeField] private List<VariousSwitches> childScripts = new List<VariousSwitches>();
    [SerializeField] private List<SwitchConditionChenge> childChengers = new List<SwitchConditionChenge>();
    [SerializeField] private bool childrenActive;

    [Header("----- XOR�A���̐ݒ� -----")]
    [SerializeField] private GameObject versusSwitch;
    [SerializeField] private VariousSwitches versusScript;


    private void Start()
    {
        // �e�����݂��Ă���Ȃ�
        if (this.transform.parent != null)
        {
            // �e�I�u�W�F�N�g���擾����
            myParent = this.transform.parent.gameObject;
            parentScript = this.transform.parent.GetComponent<VariousSwitches>();
            parentChenger = this.transform.parent.GetComponent<SwitchConditionChenge>();
            if (parentScript != null)
            {
                // �e�I�u�W�F�N�g�����݂��Ă���
                parentActive = true;

                // ���g�̖��O��ύX����
                this.gameObject.name = "childSwitch";
            }
        }

        // �q�����݂��Ă���Ȃ�
        if (this.transform.childCount != 0)
        {
            // �q�I�u�W�F�N�g�̐����擾
            int childCount = this.transform.childCount;

            // ���X�g����x����������
            myChildren.Clear();
            childScripts.Clear();
            childChengers.Clear();

            // ���g�ɂ��Ă���q�I�u�W�F�N�g���擾����
            for (int i = 0; i < childCount; i++)
            {
                // �q�I�u�W�F�N�g�����X�g���Ɋi�[
                myChildren.Add(transform.GetChild(i).gameObject);
                childScripts.Add(transform.GetChild(i).GetComponent<VariousSwitches>());
                childChengers.Add(transform.GetChild(i).GetComponent<SwitchConditionChenge>());

            }

            // �q�I�u�W�F�N�g�����݂��Ă���
            childrenActive = true;

            // ���g�̖��O��ύX����
            this.gameObject.name = "parentSwitch";

        }

        // �΂����݂��Ă���Ȃ�
        if (this.versusSwitch != null)
        {
            // �΂̃X�N���v�g�����擾
            versusScript = this.versusSwitch.GetComponent<VariousSwitches>();
        }

        // �ŏ��ɕێ����Ă���l�Ɠ��l�̏ꍇ���s
        if (nowSwitchStatus == oldSwitchStatus)
        {
            // �ێ����Ă���l��ύX����
            oldSwitchStatus = !oldSwitchStatus;

        }

    }

    private void Update()
    {
        // �X�C�b�`�̏�ԂɕύX�������ꍇ
        if (nowSwitchStatus == oldSwitchStatus)
        {
            return; // ���L�̏��������s���Ȃ�
        }


        
        // ���O�Ɍ��݂̃X�C�b�`�̏�Ԃ�ۑ�����
        oldSwitchStatus = nowSwitchStatus;

        // �e�I�u�W�F�N�g�݂̂����݂��Ă���Ȃ�
        if (parentActive && !childrenActive)
        {
            //Debug.Log("�e�̂ݑ���");

            // ���g���ύX���ꂽ�Ƃ��ɐe�̏�Ԃ�ύX����
            parentScript.nowSwitchStatus = nowSwitchStatus;

        }
        // �q�I�u�W�F�N�g�݂̂����݂��Ă���Ȃ�
        else if (childrenActive && !parentActive)
        {
            //Debug.Log("�q�̂ݑ���");

            // ���g���ύX���ꂽ�Ƃ��Ɏq�̏�Ԃ�ύX����
            for (int i = 0; i < childScripts.Count; i++)
            {
                //Debug.Log("�ύX���ꂽ��");
                if (childScripts[i] != null)
                {
                    childScripts[i].nowSwitchStatus = nowSwitchStatus;

                }
            }
        }
        // �e�q���ɃI�u�W�F�N�g�����݂��Ă��Ȃ��Ȃ�
        else if (!parentActive && !childrenActive)
        {
            //Debug.Log("�e�q���݂��Ă��Ȃ�");
        }

        // �΂����݂��Ă���Ȃ�
        if (versusSwitch != null)
        {
            // �΂Ɠ�����ԂɂȂ����Ȃ�
            if (versusScript.nowSwitchStatus == nowSwitchStatus)
            {
                //Debug.Log("�Δ���");

                // ���̏�Ԃ𔽓]������
                nowSwitchStatus = !nowSwitchStatus;

            }
        }



    }


    public void AddFamilyChangeCount()
    {
        if(parentActive)
        {
            parentChenger.AddChangeCount();
        }
        if(childrenActive)
        {
            for(byte i =0; i < childChengers.Count; i++)
            {
                if(childChengers[i] != null)
                {
                    childChengers[i].AddChangeCount();
                }
            }
        }
    }


    public void SetFamilyCoolTime()
    {
        if (parentActive)
        {
            parentChenger.SetCoolTime();
        }
        if (childrenActive)
        {
            for (byte i = 0; i < childChengers.Count; i++)
            {
                if (childChengers[i] != null)
                {
                    childChengers[i].SetCoolTime();
                }
            }
        }
    }
   

    private void OnApplicationQuit()
    {
        myChildren.Clear();
        childScripts.Clear();
        childChengers.Clear();
    }

}
