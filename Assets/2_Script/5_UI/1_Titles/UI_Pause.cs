using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class UI_Pause : MonoBehaviour
{

    [SerializeField] private Canvas pauseCanvas;

    [SerializeField] private List<Image> pauseImages = new List<Image>();

    private int pauseNum = 0;

    private float inputVertical;

    private ControlManager controlManager;
    [SerializeField]private ControllerStickMover pauseMover = new ControllerStickMover();


//    [System.Serializable]
//public struct SettingPriority
//{
//    public Slider slider; // スライダー

//    public float TarValue; // 目標値
//    public float DefValue; // 初期値
//    public float MaxValue; // 最大の値
//    public float MinValue; // 最小の値

//    public Light light;
//}
//    [SerializeField] private Canvas canvas;

//    // デバッグ用
//    [SerializeField] private Slider slider;
//    [SerializeField] private new Light light;
//    //-----

//    // 設定項目用配列
//    [SerializeField] private SettingPriority[] SliderObj;

//    private float changespeed = 1.0f;


//    private float targetBrightness; // 目標の明るさ
//    private float currentBrightness; // 現在の明るさ

    // Start is called before the first frame update
    void Start()
    {
        pauseCanvas = this.GetComponent<Canvas>();

        pauseCanvas.enabled = false;

        for(byte i=1;i<pauseCanvas.transform.childCount;i++)
        {
            pauseImages.Add(pauseCanvas.transform.GetChild(i).GetComponent<Image>());
        }

        controlManager = this.GetComponent<ControlManager>();
        if (controlManager == null) Debug.LogError("ControlManagerがありません");
        pauseMover.Start();

        pauseNum = 0;
        pauseImages[pauseNum].color = Color.red;


        //canvas = GetComponent<Canvas>();
        //// 設定数分取得する
        //for (int i = 0; i < SliderObj.Length; i++)
        //{
        //    SliderObj[i].slider = GetComponent<Slider>();
        //    SliderObj[i].light = GetComponent<Light>();
        //    // 初期値を反映する
        //    SliderObj[i].light.intensity = SliderObj[i].DefValue;
        //    SliderObj[i].slider.value = SliderObj[i].DefValue;
        //    // 最大値最小値を格納する
        //    SliderObj[i].slider.maxValue = SliderObj[i].MaxValue;
        //    SliderObj[i].slider.minValue = SliderObj[i].MinValue;
        //}
        ////slider = canvas.transform.GetChild(0).GetComponent<Slider>();
        //currentBrightness = light.intensity;
        //targetBrightness = currentBrightness;
        //slider.value = currentBrightness;
        
    }

    // Update is called once per frame
    void Update()
    {
        if(controlManager.GetPressed(ControlManager.E_GP.START))
        {
            pauseCanvas.enabled = true;
            SoundManager.Get().StopAllSE3D();
            SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_PAUSE);

        }

        if (pauseCanvas.enabled)
        {

            pauseMover.Update();

            inputVertical = pauseMover.GetMoveNum();

            if(inputVertical != 0)
            {
                InputVertical(inputVertical);
            }


            if(controlManager.GetPressed(ControlManager.E_GP.A))
            {
                SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);

                switch (pauseNum)
                {
                    case 0: pauseCanvas.enabled = false; break;
                    case 1: pauseCanvas.enabled = false; break;
                    case 2:
                        pauseCanvas.enabled = false;
                        SceneManager.LoadScene(Stage_Manager.instance.StageselectName);
                        break ;
                    case 3: 
                        pauseCanvas.enabled = false;
                        SceneManager.LoadScene(Stage_Manager.instance.worldInformation[0].worldName);
                        break ;
                }
            }


        }

        //for(int i = 0; i < SliderObj.Length; i++)
        //{
        //    // 前の値と今の値が違う時
        //    if(SliderObj[i].slider.value != SliderObj[i].TarValue)
        //    {
        //        // 変更値を格納する
        //        SliderObj[i].TarValue = SliderObj[i].slider.value;

        //        SliderObj[i].light.intensity = SliderObj[i].TarValue;
        //    }
        //}
        //if(slider.value != targetBrightness)
        //{
        //    targetBrightness = slider.value;
        //}
        //currentBrightness = Mathf.Lerp(currentBrightness, targetBrightness, changespeed);
        //light.intensity = currentBrightness;
    }

    void InputVertical(float _vertical)
    {
        // 上入力
        if(_vertical < 0)
        {
            Debug.Log("上入力");
            if(pauseNum > 0)
            {
                pauseImages[pauseNum].color = Color.white;

                pauseNum--;

                pauseImages[pauseNum].color = Color.red;
                SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

                return;
            }
        }
        // 下入力
        else if(_vertical > 0)
        {
            Debug.Log("下入力");
            if (pauseNum < pauseImages.Count-1)
            {
                pauseImages[pauseNum].color = Color.white;

                pauseNum++;

                pauseImages[pauseNum].color = Color.red;
                SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

                return;
            }
        }
    }

    private void OnApplicationQuit()
    {
        pauseImages.Clear();
    }
}
