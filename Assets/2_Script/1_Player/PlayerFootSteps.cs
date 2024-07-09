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
        /* 触れたオブジェクトのタグが"Enemy"のとき */
        if(other.CompareTag("Enemy"))
        {
            Enemy_Main otherEM = other.gameObject.GetComponent<Enemy_Main>();

            /* エネミーの基礎が入っているなら */
            if (otherEM != null)
            {
                if(otherEM.SkipOverRay(m_Player))
                {
                    // トラッキング
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
