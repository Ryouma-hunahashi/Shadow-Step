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

    [Header("作動の条件"), SerializeField]
    [Tooltip("AND：全てONならTRUE\n" + " OR：1つでもONならTRUE\n" + "XOR：ONの数が奇数ならTRUE")]
    private E_SWITCH_CONDITION condition;

    [Header("開始時の状態"), SerializeField]
    [Tooltip("OPEN：開ける\n" + "CLOSE：閉まる")]
    private E_FENCE_STATE startCondition = E_FENCE_STATE.CLOSE;

    [Header("開閉フラグ"), SerializeField]
    private bool isOpen = false;

    [Header("開く速度"), Min(0.01f), SerializeField]
    private float openSpeed = 0.3f;

    [Header("閉じる速度"), Min(0.01f), SerializeField]
    private float closeSpeed = 0.3f;

    [Header("作動用スイッチ"), SerializeField]
    private VariousSwitches[] switches;

    private Collider col = null; // 当たり判定
    private NavMeshObstacle obstacle = null;

    private GameObject fenceObj = null; // 檻

    private float maxOpenPos_Y = -3.0f; // 最大まで開いた時の深さ
    
    private bool isStayOpen = false; // 待ち状態

    void Start()
    {
        fenceObj = this.transform.GetChild(0).transform.gameObject;
        if (fenceObj == null)
        {
            Debug.LogError("檻の中心座標用子オブジェクトが存在しません");
            return;
        }
        col = GetComponent<Collider>();
        if (fenceObj == null)
        {
            Debug.LogError("檻のColliderが存在しません");
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
            // 条件を満たしているか
            isOpen = OpenCheck();
        }

        if (isOpen || isStayOpen)
        {
            //Debug.Log("開いたよ");
            fenceObj.transform.localPosition += Vector3.down * openSpeed;
            if (fenceObj.transform.localPosition.y < maxOpenPos_Y)
            {
                fenceObj.transform.localPosition = Vector3.up * maxOpenPos_Y;
            }
            col.isTrigger = true;
            obstacle.enabled = false;
            return;
        }

        //Debug.Log("閉じたよ");
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
        // Player、Enemyどちらかが範囲にいる時
        if (other.CompareTag("Enemy") ||
            other.CompareTag("Player"))
        {
            isStayOpen = true; // 開くのを待つ
            return;
        }
        isStayOpen = false;
    }


    /// <summary>
    /// 檻が開くか論理演算を行う
    /// </summary>
    private bool OpenCheck()
    {
        bool flag = (condition == E_SWITCH_CONDITION.AND) ? true : false;
        int countXOR = 0; // XOR用カウンター

        for (int i = 0; i < switches.Length; i++)
        {
            switch (condition)
            {
                case E_SWITCH_CONDITION.AND: // 1つでもfalseなら開かない
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
                case E_SWITCH_CONDITION.OR: // 1つでもtrueなら開く
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

                case E_SWITCH_CONDITION.XOR: // trueの数が奇数なら開く
                    if (switches[i].nowSwitchStatus)
                    {
                        countXOR++;
                    }
                    flag = ((countXOR % 2) == 1);
                    break;

            }
        }

        // 開始時から開いて要る場合は反転させる
        if(startCondition == E_FENCE_STATE.OPEN)
        {
            return !flag;
        }

        return flag;
    }

}





