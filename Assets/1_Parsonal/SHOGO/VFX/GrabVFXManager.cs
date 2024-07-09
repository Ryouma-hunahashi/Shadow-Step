using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class GrabVFXManager : MonoBehaviour
{
    [SerializeField, Tooltip("プレイヤーオブジェクト")]
    GameObject playerObj;
    [SerializeField, Tooltip("このVFXオブジェクトに対応している敵オブジェクト")]
    GameObject enemyObj;
    private VisualEffect effect;

    // Start is called before the first frame update
    void Start()
    {
        effect=GetComponent<VisualEffect>();
        // ゲーム開始時は停止しておく
        effect.SetBool("GrabFlg", false);
    }

    // Update is called once per frame
    void Update()
    {
        // 敵の座標を送信
        effect.SetVector3("EnemyPos",enemyObj.transform.position);
        // プレイヤーの座標を送信
        effect.SetVector3("PlayerPos",playerObj.transform.position);
        

        //// 影を掴んだとき
        //if()
        //{
        //    effect.SetBool("GrabFlg", true);
        //}
        //// 影を離すとき
        //if()
        //{
        //    effect.SetBool("GrabFlg", false);
        //}
        //// 影を消すとき
        //if ()
        //{
        //    this.gameObject.SetActive(true);
        //}
    }
}
