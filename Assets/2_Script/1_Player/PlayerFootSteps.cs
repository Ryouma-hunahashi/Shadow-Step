using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerFootSteps : MonoBehaviour
{
    private Transform playerTrans;
    private Transform trans;
    private GameObject m_Player;

    private void OnTriggerStay(Collider other)
    {
        /* �G�ꂽ�I�u�W�F�N�g�̃^�O��"Enemy"�̂Ƃ� */
        if(other.CompareTag("Enemy"))
        {
            Enemy_Main otherEM = other.gameObject.GetComponent<Enemy_Main>();

            /* �G�l�~�[�̊�b�������Ă���Ȃ� */
            if (otherEM != null)
            {
                if(otherEM.SkipOverRay(m_Player))
                {
                    // �g���b�L���O
                    otherEM.SetTracking(Enemy_Main.E_TRACKING.PLAYER);
                }
            }
        }
    }

    private void Start()
    {
        trans = this.transform;

        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        m_Player = objs[objs.Length - 1];

        playerTrans = m_Player.transform;
    }

    private void Update()
    {
        trans.position = playerTrans.position;
    }
}
