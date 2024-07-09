using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UI_Fade : MonoBehaviour
{
    // フェードの仕方を設定するアニメーションカーブ
    private AnimationCurve fadeCurve;

    // 何秒間フェードをするのか
    [SerializeField]private float fadeTime;

    private float elapsedTime;

    // フェードする値を格納する変数
    private float fadeValue;

    private bool fadeflag = false;
    private bool fadefin = false;

    /* ちょいと実験 */

    public delegate void ProcessDataEvent(float _data , Component _sender);
    public event ProcessDataEvent ProcessData;
    private Component dataSender;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (fadeflag)
        {
            fadeValue = fadeCurve.Evaluate(elapsedTime / fadeTime);
            // Updateの最後にイベントを発行する
            ProcessData?.Invoke(fadeValue, dataSender);

            elapsedTime += Time.deltaTime;
            if(elapsedTime > fadeTime)
            {
                elapsedTime = fadeTime;

                if(fadeValue == 1)
                {
                    fadeflag = true;
                    fadefin = true;
                }
            }
        }

    }

    public void SetFade(float _fade)
    {
        fadeValue = _fade;
        fadeflag = true;
    }
}
