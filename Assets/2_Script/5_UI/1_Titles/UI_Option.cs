using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using Unity.VisualScripting;
using UnityEngine.Rendering.Universal;
using System.Runtime.CompilerServices;

[System.Serializable]
public struct OptionSlider
{
    public Slider slider;  // スライダー
    public int controlNum;    // 現在の番号
}

[System.Serializable]
public struct OptionImages
{
    public Image noSelectedImage;   // not selected
    public Image backSelectedImage; // selected
    public Image selectedImage;     // back selected
}

public class UI_Option : MonoBehaviour
{
    // キャンバス系統変数宣言
    [SerializeField] private Canvas thisCanvas;
    [SerializeField] private Canvas DataFinCanvas;
    [SerializeField] private UI_Load Load;

    // オプションのイメージを格納するリスト
    [SerializeField] private List<OptionImages> optionImages = new List<OptionImages>();
    [SerializeField] private GameObject optionBGMVolume;
    [SerializeField] private GameObject optionSEVolume;
    [SerializeField] private GameObject optionLight;
    [SerializeField] private List<Image> optionFinImages = new List<Image>();

    // 音声再生スクリプト
    [SerializeField] private SoundManager soundManager;

    // 音量・光調整用構造体
    [SerializeField] private OptionSlider volumeBGMSlider;
    [SerializeField] private OptionSlider volumeSESlider;

    [SerializeField] private OptionSlider lightSlider;
    public OptionSlider GetLightSlider() { return lightSlider; }
    private int optionControlMaxNum = 10;   // 構造体最大数値

    //　インプット系統変数宣言
    [SerializeField]ControllerStickMover stickValMove;
    [SerializeField]ControllerStickMover stickHolMove;
    [SerializeField]ControlManager controlManager;
    private float stickVertical = 0;
    private float stickHorizontal = 0;

    // 現在見ている番号
    private byte optionNum;
    // 現在の状態を確認する変数
    private bool isVolume = false;
    private bool isLight = false;
    private bool isfade = false;
    private bool isLoad = false;
    private bool isCheck = false;

    // データ削除状態の時使用変数宣言
    private bool isDataFin = false;
    private bool DataFinCheck = false;

    // UI表示用変数　（一回だけ処理に使用）
    private bool isCheckUi = false;
    // このスクリプトのインスタンス
    public static  UI_Option instance;
    public bool GetOption() { return isOption; }
    public void SetOption(bool _setoption) { isOption = _setoption; }
    private bool isOption = false;

    // ポーズ用イメージ画像
    [SerializeField] private OptionImages pauseImage;

    // フェード用変数宣言
    [SerializeField] private Image fadeImage;
    [SerializeField] private AnimationCurve fadeOutCurve;   // アニメーションカーブ
    private float elapsedTime;  // 現在時間 
    [SerializeField] private float fadeOutTime = 1.0f;  // 何秒で遷移するかの変数

    public string sceneName;
    Scene scene;
    bool isInputSceneCount = true;

    private PlayerShadowMode shadowMode;

    private List<OptionImages> GetOptionImages()
    {
        return optionImages;
    }

    // Start is called before the first frame update
    void Start()
    {
        // 現在のシーンの個数を取得する
        CheckSceneCount();
        if (isInputSceneCount)
        {
            scene = SceneManager.GetSceneAt(0);
            sceneName = scene.name;
        }
        // キャンバスをコンポーネント取得する
        thisCanvas = this.GetComponent<Canvas>();
        thisCanvas.enabled = false;

        // タイトルシーンにいるかどうか確認する
        if (sceneName == Stage_Manager.instance.worldInformation[0].worldName)
        {
            Debug.Log("タイトルだからデータ削除するよ～");
            DataFinCanvas = DataFinCanvas.GetComponent<Canvas>();
            // 一旦非表示にする
            DataFinCanvas.enabled = false;
        }

        // ロードスクリプトをコンポーネントする
        Load = Load.GetComponent<UI_Load>();
        // フェード画像を取得する
        fadeImage = fadeImage.GetComponent<Image>();
        // サウンドをコンポーネントする
        soundManager = soundManager.GetComponent<SoundManager>();

        // リストに格納する
        for (int i = 2; i < 6; i++) { optionImages.Add(AddImages(i)); }
        if (DataFinCanvas != null)
        {
            for (int i = 1; i < DataFinCanvas.transform.childCount; i++) { optionFinImages.Add(DataFinCanvas.transform.GetChild(i).GetComponent<Image>()); }
        }

        if (sceneName == Stage_Manager.instance.worldInformation[0].worldName)
        {
            optionImages.RemoveAt(3);
        }
        else
        {
            optionImages.RemoveAt(2);
        }

        optionBGMVolume = this.transform.GetChild(2).GetChild(3).gameObject;
        optionSEVolume = this.transform.GetChild(2).GetChild(4).gameObject;
        optionLight = this.transform.GetChild(3).GetChild(3).gameObject;

        optionBGMVolume.transform.GetChild(2).GetComponent<Image>().enabled = false;
        optionSEVolume.transform.GetChild(2).GetComponent<Image>().enabled = false;

        optionBGMVolume.SetActive(false);
        optionSEVolume.SetActive(false);
        optionLight.SetActive(false);

        // スライダーを初期設定する（音量）
        volumeBGMSlider.slider = optionBGMVolume.transform.GetChild(0).GetComponent<Slider>();
        volumeBGMSlider.controlNum = 10;
        volumeBGMSlider.slider.value = 1.0f / optionControlMaxNum * volumeBGMSlider.controlNum;
        volumeSESlider.slider = optionSEVolume.transform.GetChild(0).GetComponent<Slider>();
        volumeSESlider.controlNum = 10;
        volumeSESlider.slider.value = 1.0f / optionControlMaxNum * volumeSESlider.controlNum;
        
        // スライダーを初期設定する（光）
        lightSlider.slider = optionLight.transform.GetChild(0).GetComponent<Slider>();
        lightSlider.controlNum = 5;
        lightSlider.slider.value = 1.0f / optionControlMaxNum * lightSlider.controlNum;

        // インプット系統を初期化する
        controlManager = this.GetComponent<ControlManager>();
        stickValMove = new ControllerStickMover();
        stickValMove.Start();
        stickHolMove = new ControllerStickMover();
        stickHolMove.Start();
        StickSet();

        // 最初の初期値を設定しておく
        optionNum = 0;
        ChangeSelected(optionNum);

        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        if (objs.Length > 0)
        {
            shadowMode = objs[objs.Length - 1].GetComponent<PlayerShadowMode>();
        }
    }

    // Update is called once per frame
    void Update()
    {
        if(sceneName != "Title" && !thisCanvas.enabled)
        {
            if(sceneName == "")
            {
                scene = SceneManager.GetSceneAt(0);
                sceneName = scene.name;
            }
            InputTrueCheckButton();
            return;
        }
        // データを削除するとき
        if (isDataFin)
        {
            stickHorizontal = stickHolMove.GetMoveNum();
            InputValtoHor();
            if (stickHorizontal != 0) { OptionHorizontal(stickHorizontal); }


            if (DataFinCheck)
            {   // はいのとき
                optionFinImages[0].color = Color.red;
                optionFinImages[1].color = Color.white;
            }
            else
            {   // いいえのとき
                optionFinImages[0].color = Color.white;
                optionFinImages[1].color = Color.red;
            }
            // 決定キーが押されたとき
            if (controlManager.GetPressed(ControlManager.E_GP.A) || controlManager.GetPressed(ControlManager.E_KB.ENTER))
            {
                // はいのとき
                if (DataFinCheck && !isCheck)
                {
                    // タイトル戻る
                    isfade = true;
                    isCheck = true;
                }
                // いいえのとき
                else
                {
                    // データ削除状態を全部オフにする
                    isDataFin = false;
                    DataFinCheck = false;
                    DataFinCanvas.enabled = false;
                }
                return;
            }
        }
        // オプション状態か確認する
        if (thisCanvas.enabled && !isDataFin)
        {
            // UIを一回だけ表示する
            CheckOneDrawUi();
            // 入力処理されているか
            InputTrueCheckButton();
            stickVertical = stickValMove.GetMoveNum();
            stickHorizontal = stickHolMove.GetMoveNum();
            InputValtoHor();
            // 縦情報入力されたとき処理を行う
            if (stickVertical != 0) { OptionVertical(stickVertical); }
            if (stickHorizontal != 0) { OptionHorizontal(stickHorizontal); }
        }
        if(isfade)
        {
            var color = fadeImage.color;
            color.a = fadeOutCurve.Evaluate(elapsedTime / fadeOutTime);
            fadeImage.color = color;

            elapsedTime += Time.deltaTime;
            if (elapsedTime > fadeOutTime)
            {
                elapsedTime = fadeOutTime;

                if (fadeImage.color.a == 1)
                {
                    isLoad = true;
                    isfade = false;
                    return;
                }
            }
        }

        if(isLoad && !isCheck)
        {
            // 一回だけ処理を行う
            // タイトルに戻る
            if (sceneName == Stage_Manager.instance.worldInformation[0].worldName)
            {
                Load.StartLoad("Title");
            }
            else
            {
                Load.StartLoad(Stage_Manager.instance.StageselectName);
            }
            isLoad = false;
            isCheck = true;
        }

    }

    void OptionVertical(float _vertical)
    {
        // 上方向入力
        if (_vertical < 0)
        {
            if(isVolume)
            {
               var BGMColor = optionBGMVolume.transform.GetChild(2).GetComponent<Image>();
               var SEColor = optionSEVolume.transform.GetChild(2).GetComponent<Image>();
                BGMColor.enabled = true;
                SEColor.enabled = false;
                return;
            }
            if (optionNum > 0)
            {
                ChangeNoSelected(optionNum);

                optionNum--;
               //if (optionNum == 2 && sceneName != Stage_Manager.instance.worldInformation[0].worldName)
               //{ optionNum--; }

                ChangeSelected(optionNum);
            }
            isCheckUi = !isCheckUi;
            return;
        }
        // 下方向入力
        else if(_vertical >0)
        {
            if (isVolume)
            {
                var BGMColor = optionBGMVolume.transform.GetChild(2).GetComponent<Image>();
                var SEColor = optionSEVolume.transform.GetChild(2).GetComponent<Image>();
                BGMColor.enabled = false;
                SEColor.enabled = true;
                return;
            }
         
            if (optionNum < optionImages.Count-1)
            {
                ChangeNoSelected(optionNum);

                optionNum++;
                //if(optionNum == 2 && sceneName != Stage_Manager.instance.worldInformation[0].worldName) 
                //{ optionNum++; }

                ChangeSelected(optionNum);
            }
            isCheckUi = !isCheckUi;
            return;
        }
    }

    void OptionHorizontal(float _horizontal)
    {
        // 右方向入力
        if (_horizontal < 0)
        {
            if (isDataFin)  // データ削除状態
            {
                DataFinCheck = false;
            }
            else if (optionNum == 0 && isVolume)    // 音量調節
            {
                
                var volumeColor = optionBGMVolume.transform.GetChild(2).GetComponent<Image>();
                if (volumeColor.enabled)
                {
                    if(volumeBGMSlider.controlNum >= optionControlMaxNum) { return; }
                    volumeBGMSlider.controlNum++;
                    volumeBGMSlider.slider.value = 1.0f / optionControlMaxNum * volumeBGMSlider.controlNum;

                    Debug.Log(volumeBGMSlider.controlNum);
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);
                    soundManager.SetVolumeBGM(volumeBGMSlider.slider.value);
                }
                else
                {
                    if (volumeSESlider.controlNum >= optionControlMaxNum) { return; }
                    volumeSESlider.controlNum++;
                    volumeSESlider.slider.value = 1.0f / optionControlMaxNum * volumeSESlider.controlNum;

                    Debug.Log(volumeBGMSlider.controlNum);

                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);
                    soundManager.SetVolumeSE(volumeSESlider.slider.value);
                }
            }
            else if(optionNum ==1 && isLight)
            {
                lightSlider.controlNum++;
                lightSlider.slider.value = 1.0f / optionControlMaxNum * lightSlider.controlNum;

                SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

            }
        }
        // 左方向入力
        else if (_horizontal > 0)
        {
           if (isDataFin)   // データ削除状態
            {
                DataFinCheck = true;
            }
            else if (optionNum == 0 && isVolume)    // 音量調節
            {
               var volumeColor = optionBGMVolume.transform.GetChild(2).GetComponent<Image>();
               if (volumeColor.enabled)
               {
                    if(volumeBGMSlider.controlNum <= 0) { return; }
                    volumeBGMSlider.controlNum--;
                    volumeBGMSlider.slider.value = 1.0f / optionControlMaxNum * volumeBGMSlider.controlNum;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);
                    soundManager.SetVolumeBGM(volumeBGMSlider.slider.value);

               }
               else
               {
                    if (volumeSESlider.controlNum <= 0) { return; }
                    volumeSESlider.controlNum--;
                    volumeSESlider.slider.value = 1.0f / optionControlMaxNum * volumeSESlider.controlNum;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);
                    soundManager.SetVolumeSE(volumeSESlider.slider.value);
               }

            }
            else if (optionNum == 1 && isLight)
            {
                lightSlider.controlNum--;
                lightSlider.slider.value = 1.0f / optionControlMaxNum * lightSlider.controlNum;

                SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

            }
        }
        return;
    }

    // スティック初期設定
    void StickSet()
    {
        stickValMove.SetReverse(true);
        stickValMove.SetStickType(ControllerStickMover.STICK_MOVE_TYPE.STICK_VERTICAL);
        stickHolMove.SetReverse(true);
        stickHolMove.SetStickType(ControllerStickMover.STICK_MOVE_TYPE.STICK_HORIZONTAL);
    }

    // 十字キー入力処理
    void InputValtoHor()
    {
        if (controlManager.GetPressed(ControlManager.E_GP.UP))
        {
            stickVertical = -1;
        }
        else if (controlManager.GetPressed(ControlManager.E_GP.DOWN))
        {
            stickVertical = 1;
        }
        if (controlManager.GetPressed(ControlManager.E_GP.LEFT))
        {
            stickHorizontal = 1;
        }
        else if (controlManager.GetPressed(ControlManager.E_GP.RIGHT))
        {
            stickHorizontal = -1;
        }
    }

    // 一度だけ表示する処理
    void CheckOneDrawUi()
    {
        if(isCheckUi) { return; }
        if (optionNum == 0)
        {
            optionBGMVolume.SetActive(true);
            optionSEVolume.SetActive(true);
            optionLight.SetActive(false);
            isCheckUi = true;
        }
        else if(optionNum == 1)
        {
            optionBGMVolume.SetActive(false);
            optionSEVolume.SetActive(false);
            optionLight.SetActive(true);
            isCheckUi = true;
        }
        else
        {
            optionBGMVolume.SetActive(false);
            optionSEVolume.SetActive(false);
            optionLight.SetActive(false);
            isCheckUi = true;
        }
    }

    // 決定ボタンを押したとき処理
    void InputTrueCheckButton()
    {
        if (thisCanvas.enabled)
        {
            if (controlManager.GetPressed(ControlManager.E_GP.A) || controlManager.GetPressed(ControlManager.E_KB.ENTER))
            {
                if (!isLight && optionNum == 1)
                {
                    isLight = true;
                    optionLight.transform.GetChild(1).GetComponent<Image>().color = Color.red;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);
                    return;
                }
                else if (!isVolume && optionNum == 0)
                {
                    isVolume = true;
                    optionBGMVolume.transform.GetChild(2).GetComponent<Image>().enabled = true;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);
                    return;
                }
                else if (optionNum == 2)
                {
                    if (sceneName == Stage_Manager.instance.worldInformation[0].worldName)
                    {
                        isDataFin = true;
                        DataFinCanvas.enabled = true;
                        SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);

                    }
                    else 
                    {
                        isfade = true;
                        SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);

                    }
                    return;
                }
            }
            else if (controlManager.GetPressed(ControlManager.E_GP.B) || controlManager.GetPressed(ControlManager.E_KB.SPACE))
            {
                if (isLight)
                {
                    isLight = false;
                    optionLight.transform.GetChild(1).GetComponent<Image>().color = Color.white;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CANCEL);
                    return;
                }
                else if (isVolume)
                {
                    isVolume = false;
                    optionBGMVolume.transform.GetChild(2).GetComponent<Image>().enabled = false;
                    optionSEVolume.transform.GetChild(2).GetComponent<Image>().enabled = false;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CANCEL);
                    return;
                }
                else
                {
                    thisCanvas.enabled = false;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CANCEL);
                    return; 
                }
            }
        }

        if(sceneName != Stage_Manager.instance.worldInformation[0].worldName && 
            (controlManager.GetPressed(ControlManager.E_GP.SELECT) || controlManager.GetPressed(ControlManager.E_KB.P)))
        {
            thisCanvas.enabled = !thisCanvas.enabled;
            shadowMode.isPause = thisCanvas.enabled;
            SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CANCEL);
            return;
        }
    }

    // 選択状態切り替え処理
    private void ChangeSelected(byte _num)
    {
        optionImages[_num].noSelectedImage.enabled = false;
        optionImages[_num].backSelectedImage.enabled = true;
        optionImages[_num].selectedImage.enabled = true;
    }

    // 未選択状態切り替え処理
    private void ChangeNoSelected(byte _num)
    {
        optionImages[_num].noSelectedImage.enabled = true;
        optionImages[_num].backSelectedImage.enabled = false;
        optionImages[_num].selectedImage.enabled = false;
    }

    // イメージを格納する処理
    private OptionImages AddImages(int _i)
    {
        var trans = this.transform.GetChild(_i);
        OptionImages image;

        image.noSelectedImage = trans.GetChild(0).GetComponent<Image>();
        image.backSelectedImage = trans.GetChild(1).GetComponent<Image>();
        image.selectedImage = trans.GetChild(2).GetComponent<Image>();

        image.backSelectedImage.enabled = false;
        image.selectedImage.enabled = false;

        // 二番目(DataDel)、タイトル以外の時
        if (_i == 4 && sceneName != Stage_Manager.instance.worldInformation[0].worldName)
        {
            image.noSelectedImage.enabled = false;
        }
        // 三番目(Pause)、タイトルの時
        if( _i == 5 && sceneName == Stage_Manager.instance.worldInformation[0].worldName)
        {
            image.noSelectedImage.enabled = false;
        }

        return image;
    }

    private void CheckSceneCount()
    {
        int sceneCount = SceneManager.sceneCount;
        isInputSceneCount = sceneCount <= 1;
        Debug.Log(SceneManager.sceneCount);
        if(SceneManager.sceneCount == 2)
        {
            Scene scene = SceneManager.GetSceneAt(1);
            if(scene.name == Stage_Manager.instance.worldInformation[0].worldName)
            {
                sceneName = scene.name;
            }
        }
        Debug.Log(isInputSceneCount);
    }

    // リスト解放処理
    private void OnApplicationQuit()
    {
        optionImages.Clear();
        optionFinImages.Clear();
    }
}
