using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Runtime.CompilerServices;
using Unity.VisualScripting;
using System;

[System.Serializable]
public struct ResultImages
{
    public Image noSelectedImage;   // no selected 
    public Image backSelectedImage; // back selected
    public Image selectedImage;     // selected
}

public class UI_Result : MonoBehaviour
{
    // イメージを格納するリスト
    [SerializeField] private List<ResultImages> images = new List<ResultImages>();

    // 他スクリプト変数
    [SerializeField] private UI_Load loader;
    [SerializeField] private PlayerShadowMode shadowMode;

    // インプット系統変数
    ControllerStickMover stickmover = new ControllerStickMover();
    [SerializeField]ControlManager controlManager;
    private float inputVel;

    // 今見ている番号
    byte resultNum = 0;

    // 自信を保持する変数
    private Canvas thisCanvas;

    // fade用変数
    [SerializeField] private Image fadeImage;
    [SerializeField] private AnimationCurve fadeCurve;
    private float elapsedTime;  // 現在時間 
    [SerializeField] private float fadeOutTime = 1.0f;  // 何秒で遷移するかの変数
    private bool nowfade = false;
    private bool setResult = false;
    private bool isLoad = false;
    private bool isCheck = false;

    IEnumerator setTime()
    {
        yield return new WaitForSeconds(0.75f);
        thisCanvas.enabled = true; setResult = true;
    }

    // Start is called before the first frame update
    void Start()
    {
        shadowMode = shadowMode.GetComponent<PlayerShadowMode>();
        fadeImage = fadeImage.GetComponent<Image>();
        loader = loader.GetComponent<UI_Load>();
        thisCanvas = this.GetComponent<Canvas>();

        for (byte i = 1; i < 3; i++) 
        {
            images.Add(AddImages(i));
        }

        controlManager = GetComponent<ControlManager>();
        stickmover = new ControllerStickMover();
        stickmover.Start();
        stickmover.SetStickType(ControllerStickMover.STICK_MOVE_TYPE.STICK_VERTICAL);

        ChangeSelected(resultNum);

        thisCanvas.enabled = false;
    }

    // Update is called once per frame
    void Update()
    {
        //Debug.Log(shadowMode.endFg);
        if (shadowMode.endFg)
        {
            shadowMode.isPause = true;
            if(!setResult) 
            {
                StartCoroutine(setTime());
            }
            inputVel = stickmover.GetMoveNum();
            Debug.Log($"{inputVel}");
            if (inputVel != 0) { ChangeNum(inputVel); }

            // 決定押されたら
            if (controlManager.GetPressed(ControlManager.E_GP.A) || controlManager.GetPressed(ControlManager.E_KB.ENTER))
            {
                if(!nowfade)
                {
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);

                }
                nowfade = true;
            }
            if (nowfade)
            {
                var color = fadeImage.color;
                color.a = fadeCurve.Evaluate(elapsedTime / fadeOutTime);
                fadeImage.color = color;

                elapsedTime += Time.deltaTime;
                if (elapsedTime > fadeOutTime)
                {
                    elapsedTime = fadeOutTime;

                    if (fadeImage.color.a == 1)
                    {
                        isLoad = true;
                        
                    }
                }
            }
            if(isLoad && !isCheck)
            {
                switch (resultNum)
                {
                    case 0:
                        // 一加算して次のステージへ
                        Stage_Manager.instance.SetStageNum((byte)(Stage_Manager.instance.GetStageNum() + (byte)1));
                        if (Stage_Manager.instance.GetStageNum() > Stage_Manager.instance.worldInformation[Stage_Manager.instance.GetWorldNum()].stageInformation.Count + 1)
                        {

                            Stage_Manager.instance.SetWorldNum((byte)(Stage_Manager.instance.GetWorldNum() + (byte)1));
                            Stage_Manager.instance.SetStageNum(0);

                        }
                        Debug.Log((Stage_Manager.instance.GetWorldNum()) + "-" + (Stage_Manager.instance.GetStageNum()));
                        loader.StartLoad(
                            Stage_Manager.instance.worldInformation[Stage_Manager.instance.GetWorldNum()].
                            stageInformation[Stage_Manager.instance.GetStageNum()].stageName);
                        nowfade = false;
                        isLoad = false;
                        break;
                    case 1:
                        loader.StartLoad(Stage_Manager.instance.StageselectName);
                        nowfade = false;
                        isLoad = false;
                        break;
                }
                isCheck = true;
            }
        }
    }

    void ChangeNum(float _input)
    {
        if (inputVel > 0)
        {
            if (resultNum != 0)
            {
                ChangeNoSelected(resultNum);

                resultNum--;

                ChangeSelected(resultNum);
                SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

            }
        }
        else if (inputVel < 0)
        {
            if (resultNum == 0)
            {
                ChangeNoSelected(resultNum);

                resultNum++;

                ChangeSelected(resultNum);
                SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

            }
        }
    }

    void ChangeNoSelected(byte _num)
    {
        images[_num].noSelectedImage.enabled = true;
        images[_num].backSelectedImage.enabled = false;
        images[_num].selectedImage.enabled = false;
    }

    void ChangeSelected(byte _num)
    {
        images[_num].noSelectedImage.enabled = false;
        images[_num].backSelectedImage.enabled = true;
        images[_num].selectedImage.enabled = true;
    }

    private ResultImages AddImages( byte _i)
    {
        var trans = this.transform.GetChild(_i);

        ResultImages image;

        image.noSelectedImage = trans.transform.GetChild(0).GetComponent<Image>();
        image.backSelectedImage = trans.transform.GetChild(1).GetComponent<Image>();
        image.selectedImage = trans.transform.GetChild(2).GetComponent<Image>();

        image.backSelectedImage.enabled = false;
        image.selectedImage.enabled = false;

        return image;
        
    }

    private void OnApplicationQuit()
    {
        images.Clear();
    }
}
