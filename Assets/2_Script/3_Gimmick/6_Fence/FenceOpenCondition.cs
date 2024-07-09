using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class FenceOpenCondition : MonoBehaviour
{
    private enum E_SWITCH_CONDITION
    {
        AND, OR, XOR,
    }

    private enum E_FENCE_STATE
    {
        OPEN,CLOSE
    }

    [Header("�쓮�̏���"), SerializeField]
    [Tooltip("AND�F�S��ON�Ȃ�TRUE\n" + " OR�F1�ł�ON�Ȃ�TRUE\n" + "XOR�FON�̐�����Ȃ�TRUE")]
    private E_SWITCH_CONDITION condition;

    [Header("�J�n���̏��"), SerializeField]
    [Tooltip("OPEN�F�J����\n" + "CLOSE�F�܂�")]
    private E_FENCE_STATE startCondition = E_FENCE_STATE.CLOSE;

    [Header("�J�t���O"), SerializeField]
    private bool isOpen = false;

    [Header("�J�����x"), Min(0.01f), SerializeField]
    private float openSpeed = 0.3f;

    [Header("���鑬�x"), Min(0.01f), SerializeField]
    private float closeSpeed = 0.3f;

    [Header("�쓮�p�X�C�b�`"), SerializeField]
    private VariousSwitches[] switches;

    private Collider col = null; // �����蔻��
    private NavMeshObstacle obstacle = null;

    private GameObject fenceObj = null; // �B

    private float maxOpenPos_Y = -3.0f; // �ő�܂ŊJ�������̐[��
    
    private bool isStayOpen = false; // �҂����

    void Start()
    {
        fenceObj = this.transform.GetChild(0).transform.gameObject;
        if (fenceObj == null)
        {
            Debug.LogError("�B�̒��S���W�p�q�I�u�W�F�N�g�����݂��܂���");
            return;
        }
        col = GetComponent<Collider>();
        if (fenceObj == null)
        {
            Debug.LogError("�B��Collider�����݂��܂���");
            return;
        }
        obstacle = GetComponent<NavMeshObstacle>();

        if (startCondition == E_FENCE_STATE.OPEN)
        {
            fenceObj.transform.localPosition = Vector3.up * maxOpenPos_Y;
            isOpen = true;
        }
    }



    void Update()
    {
        if (switches.Length > 0)
        {
            // �����𖞂����Ă��邩
            isOpen = OpenCheck();
        }

        if (isOpen || isStayOpen)
        {
            //Debug.Log("�J������");
            fenceObj.transform.localPosition += Vector3.down * openSpeed;
            if (fenceObj.transform.localPosition.y < maxOpenPos_Y)
            {
                fenceObj.transform.localPosition = Vector3.up * maxOpenPos_Y;
            }
            col.isTrigger = true;
            obstacle.enabled = false;
            return;
        }

        //Debug.Log("������");
        fenceObj.transform.localPosition += Vector3.up * closeSpeed;
        if (fenceObj.transform.localPosition.y > 0.0f)
        {
            fenceObj.transform.localPosition = Vector3.zero;
        }
        col.isTrigger = false;
        obstacle.enabled= true;

    }

    private void OnTriggerStay(Collider other)
    {
        // Player�AEnemy�ǂ��炩���͈͂ɂ��鎞
        if (other.CompareTag("Enemy") ||
            other.CompareTag("Player"))
        {
            isStayOpen = true; // �J���̂�҂�
            return;
        }
        isStayOpen = false;
    }


    /// <summary>
    /// �B���J�����_�����Z���s��
    /// </summary>
    private bool OpenCheck()
    {
        bool flag = (condition == E_SWITCH_CONDITION.AND) ? true : false;
        int countXOR = 0; // XOR�p�J�E���^�[

        for (int i = 0; i < switches.Length; i++)
        {
            switch (condition)
            {
                case E_SWITCH_CONDITION.AND: // 1�ł�false�Ȃ�J���Ȃ�
                    flag &= switches[i].nowSwitchStatus;
                    //if (!switches[i].nowSwitchStatus)
                    //{
                    //    flag = false;
                    //    i = switches.Length;
                    //}
                    //else
                    //{
                    //    flag = true;
                    //}
                    break;
                case E_SWITCH_CONDITION.OR: // 1�ł�true�Ȃ�J��
                    flag |= switches[i].nowSwitchStatus;
                    //if (switches[i].nowSwitchStatus)
                    //{
                    //    flag = true;
                    //}
                    //else
                    //{
                    //    flag = false;
                    //}
                    break;

                case E_SWITCH_CONDITION.XOR: // true�̐�����Ȃ�J��
                    if (switches[i].nowSwitchStatus)
                    {
                        countXOR++;
                    }
                    flag = ((countXOR % 2) == 1);
                    break;

            }
        }

        // �J�n������J���ėv��ꍇ�͔��]������
        if(startCondition == E_FENCE_STATE.OPEN)
        {
            return !flag;
        }

        return flag;
    }

}





