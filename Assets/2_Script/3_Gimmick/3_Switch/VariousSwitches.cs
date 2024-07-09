using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class VariousSwitches : MonoBehaviour
{
    [Tooltip("スイッチの状態")]
    public  bool nowSwitchStatus;   // 現在の状態
    private bool oldSwitchStatus;   // 前回の状態

    [Header("----- 連動時の設定 -----"), Space(5)]
    [SerializeField] private GameObject myParent; // 親オブジェクトの取得
    [SerializeField] private VariousSwitches parentScript;
    [SerializeField] private SwitchConditionChenge parentChenger;
    [SerializeField] private bool parentActive;

    [SerializeField] private List<GameObject> myChildren = new List<GameObject>();  // 子オブジェクトの取得
    [SerializeField] private List<VariousSwitches> childScripts = new List<VariousSwitches>();
    [SerializeField] private List<SwitchConditionChenge> childChengers = new List<SwitchConditionChenge>();
    [SerializeField] private bool childrenActive;

    [Header("----- XOR連動の設定 -----")]
    [SerializeField] private GameObject versusSwitch;
    [SerializeField] private VariousSwitches versusScript;


    private void Start()
    {
        // 親が存在しているなら
        if (this.transform.parent != null)
        {
            // 親オブジェクトを取得する
            myParent = this.transform.parent.gameObject;
            parentScript = this.transform.parent.GetComponent<VariousSwitches>();
            parentChenger = this.transform.parent.GetComponent<SwitchConditionChenge>();
            if (parentScript != null)
            {
                // 親オブジェクトが存在している
                parentActive = true;

                // 自身の名前を変更する
                this.gameObject.name = "childSwitch";
            }
        }

        // 子が存在しているなら
        if (this.transform.childCount != 0)
        {
            // 子オブジェクトの数を取得
            int childCount = this.transform.childCount;

            // リストを一度初期化する
            myChildren.Clear();
            childScripts.Clear();
            childChengers.Clear();

            // 自身についている子オブジェクトを取得する
            for (int i = 0; i < childCount; i++)
            {
                // 子オブジェクトをリスト内に格納
                myChildren.Add(transform.GetChild(i).gameObject);
                childScripts.Add(transform.GetChild(i).GetComponent<VariousSwitches>());
                childChengers.Add(transform.GetChild(i).GetComponent<SwitchConditionChenge>());

            }

            // 子オブジェクトが存在している
            childrenActive = true;

            // 自身の名前を変更する
            this.gameObject.name = "parentSwitch";

        }

        // 対が存在しているなら
        if (this.versusSwitch != null)
        {
            // 対のスクリプト情報を取得
            versusScript = this.versusSwitch.GetComponent<VariousSwitches>();
        }

        // 最初に保持している値と同値の場合実行
        if (nowSwitchStatus == oldSwitchStatus)
        {
            // 保持している値を変更する
            oldSwitchStatus = !oldSwitchStatus;

        }

    }

    private void Update()
    {
        // スイッチの状態に変更が無い場合
        if (nowSwitchStatus == oldSwitchStatus)
        {
            return; // 下記の処理を実行しない
        }


        
        // ログに現在のスイッチの状態を保存する
        oldSwitchStatus = nowSwitchStatus;

        // 親オブジェクトのみが存在しているなら
        if (parentActive && !childrenActive)
        {
            //Debug.Log("親のみ存在");

            // 自身が変更されたときに親の状態を変更する
            parentScript.nowSwitchStatus = nowSwitchStatus;

        }
        // 子オブジェクトのみが存在しているなら
        else if (childrenActive && !parentActive)
        {
            //Debug.Log("子のみ存在");

            // 自身が変更されたときに子の状態を変更する
            for (int i = 0; i < childScripts.Count; i++)
            {
                //Debug.Log("変更された数");
                if (childScripts[i] != null)
                {
                    childScripts[i].nowSwitchStatus = nowSwitchStatus;

                }
            }
        }
        // 親子共にオブジェクトが存在していないなら
        else if (!parentActive && !childrenActive)
        {
            //Debug.Log("親子存在していない");
        }

        // 対が存在しているなら
        if (versusSwitch != null)
        {
            // 対と同じ状態になったなら
            if (versusScript.nowSwitchStatus == nowSwitchStatus)
            {
                //Debug.Log("対判定");

                // 今の状態を反転させる
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
