using System.Collections;
using System.Collections.Generic;
using UnityEngine;
// VFXを使うために必要
using UnityEngine.VFX;
public class VFXManager : MonoBehaviour
{
    private VisualEffect effect;
    // 影の長さ
    [SerializeField]
    private float length;
    // 影の方向
    [SerializeField]
    private Vector3 direction;
    
    // Start is called before the first frame update
    void Start()
    {
        // オブジェクトからVFXコンポーネントを取得
        effect = this.GetComponent<VisualEffect>();
        
    }

    // Update is called once per frame
    void Update()
    {
        // 影の長さを送信
        effect.SetFloat("length", length);
        // 影の方向を送信
        effect.SetVector3("Direction",direction);
        // 影の始点を送信
        effect.SetVector3("position", transform.position);

        //// 影をつかんだ時
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
        //    effect.SetBool("GrabFlg", false);
        //    this.gameObject.SetActive(false);

        //}
    }

}
