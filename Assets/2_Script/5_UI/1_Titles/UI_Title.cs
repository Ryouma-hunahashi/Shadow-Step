using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

[System.Serializable]
public struct TitleImages
{
    public Image noSelectedImage;   // no selected 
    public Image backSelectedImage; // back selected
    public Image selectedImage;     // selected
}

public class UI_Title : MonoBehaviour
{
    [SerializeField] private Canvas ui_title;       // タイトルキャンバス
    [SerializeField] private Canvas ui_option;      // オプションキャンバス
    [SerializeField] private UI_Load loadCanvas;    // ロード用キャンバス
    [SerializeField] private UI_Option option;      // オプションスクリプト

    // タイトルのイメージを格納するリスト
    [SerializeField] private List<TitleImages> Images = new List<TitleImages>();
    // フェード用イメージ
    [SerializeField] private Image fadeImage;

    /* 入力用変数 */
    private ControlManager controlManager;   // マネージャー
    // スティック入力用クラス
    [SerializeField]private ControllerStickMover mover = new ControllerStickMover();
    private float stickVertical;  // 縦入力数値格納用変数

    private byte titleNum = 1;   // 現在見ている番号

    /* フェード用変数　※フェードだけのスクリプトを作成する予定 */
    [SerializeField] private AnimationCurve fadeOutCurve;   // アニメーションカーブ
    private float elapsedTime;  // 現在時間 
    [SerializeField] private float fadeOutTime = 1.0f;  // 何秒で遷移するかの変数

    /* フラグ用変数 */
    public  bool gameStartFlg = false;  // ゲームスタートが押されているか確認用
    private bool nowfade = false;       // 現在フェードをしているか確認用
    private bool isLoad = false;        // 現在ロードしているか確認用
    private bool isCheck = false;       // シーン移動が動作しているか確認用

    // ※UIが来た時に変更する
    [SerializeField] private Image StartTitleImage;                   
    [SerializeField] private float startFadeTime = 3.0f;        // 指定秒間alpha移動
    [SerializeField] private AnimationCurve pressButtonCurve;   // アニメーションカーブ   

    // シーン保持変数
    private bool isInputSceneCount = true;

    void Start()
    {
      
        // スクリプト取得
        ui_title = GetComponent<Canvas>();
        if (ui_title == null) { Debug.LogError("ui_titleがセットされていません"); }
        ui_title.enabled = false;

        ui_option = ui_option.GetComponent<Canvas>();
        if (ui_option == null) { Debug.LogError("ui_optionがセットされていません"); }
        ui_option.enabled = false;
        //option = GetComponent<UI_Option>();

        loadCanvas = loadCanvas.GetComponent<UI_Load>();
        if (loadCanvas == null) { Debug.LogError("loadCanvasがセットされていません"); }

        for (byte i = 1; i < ui_title.transform.childCount-2; i++)
        {
            Images.Add(AddImages(i));
        }

        fadeImage = fadeImage.GetComponent<Image>();
        /* 入力系初期化 */
        // 入力用マネージャー取得
        controlManager = GetComponent<ControlManager>();
        if (controlManager == null) { Debug.LogError("ControlManagerがセットされていません"); }
        mover.Start();
        mover.SetStickType(ControllerStickMover.STICK_MOVE_TYPE.STICK_VERTICAL);

        /* 初期化設定 */

        titleNum = 1;
        ChangeSelected(titleNum);

        StartTitleImage = StartTitleImage.GetComponent<Image>();
        // キーフレームの前の処理を制御する
        pressButtonCurve.preWrapMode = WrapMode.Loop;
        // キーフレームの後の処理を制御する
        pressButtonCurve.postWrapMode = WrapMode.Loop;

        SoundManager.Get().SetBlendTrans(0);
        //SoundManager.Get().ChangeGroupBGM(E_BGM_TYPE.TITLE, SoundManager.E_BGM_STATE.DEFAUL);
        //SoundManager.Get().PlayBGM();
    }

    // Update is called once per frame
    void Update()
    {
        CheckSceneCount();
        // 何か押されたとき
        if (TitleStart() && !ui_option.enabled)
        {
            if (isInputSceneCount)
            {
                // 縦入力を取得する
                stickVertical = mover.GetMoveNum();
                // 十字キー入力処理
                CrossinputNum();

                // 横入力が入力されているとき
                if (stickVertical != 0)
                {
                    SelectVertical(stickVertical);
                }
                // ボタン入力処理
                InputButton();
                // フェード処理
                if (nowfade)
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
                            nowfade = false;
                            return;
                        }
                    }
                }
                // ロード状態に入ったら
                if (isLoad)
                {
                    // 一回だけ処理を行う（何回も入るとシーンが複数出力される）
                    loadCanvas.StartLoad(Stage_Manager.instance.StageselectName);
                    isLoad = false;
                }
            }
        }
        else
        {
            InputButton();

            var text = StartTitleImage.color;
            text.a = pressButtonCurve.Evaluate(elapsedTime / startFadeTime);
            StartTitleImage.color = text;

            elapsedTime += Time.deltaTime;
            if (elapsedTime > startFadeTime)
            {
                elapsedTime = 0.0f;
                startFadeTime = 3.0f;
            }
        }
    }

    // ボタンが押されたときの処理
    void InputButton()
    {
        // 決定ボタン（GP：A　KB：Enter）が押されたとき
        if(controlManager.GetPressed(ControlManager.E_GP.A)|| controlManager.GetPressed(ControlManager.E_KB.ENTER))
        {
            // 最初の状態が解除されていないとき
            if (!gameStartFlg) { gameStartFlg = true; return; }
            else
            {
                // 一度入力処理を入ったら連打して入らないように対策をしておく
                // ※音が複数回なるのを防ぐメリットもある
                if(isCheck) { return; }
                isCheck = true;
                SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);
                // 入力時に対応している状態に遷移する
                switch (titleNum)
                {
                    case 2: // オプション
                        ui_option.enabled = true;
                        isCheck = false;
                        break;
                    case 3: // ゲーム終了
                        GameEnd();
                        break;
                    default:
                        nowfade = true;
                        break;
                }
            }
        }
    }

    // スティック入力時処理
    void SelectVertical(float _Vertical)
    {
        // 横入力（左）の時
        if(_Vertical < 0)
        {
            if(titleNum > 0)
            {
                ChangeNoSelected(titleNum);

                titleNum--;

                ChangeSelected(titleNum);
            }
            return;
        }
        else if(stickVertical > 0)
        {
            if(titleNum < Images.Count-1)
            {
                ChangeNoSelected(titleNum);

                titleNum++;

                ChangeSelected(titleNum);
            }
            return;
        }
    }

    // 十字キー入力時処理
    void CrossinputNum()
    {
        if(stickVertical != 0) { return; }
        if (controlManager.GetPressed(ControlManager.E_GP.UP))
        {
            stickVertical = -1;
        }
        else if (controlManager.GetPressed(ControlManager.E_GP.DOWN))
        {
            stickVertical = 1;
        }
    }

    // PressStart状態
    bool TitleStart()
    {
        if(!gameStartFlg)
        {
            return false;
        }

        ui_title.enabled = true;
        StartTitleImage.enabled = false;
        return true;
    }

    // 選択されている状態に変更するとき
    void ChangeSelected(byte _num)
    {
        if (_num != titleNum)
        {
            SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);
        }
        Images[_num].noSelectedImage.enabled = false;
        Images[_num].selectedImage.enabled = true;
        Images[_num].backSelectedImage.enabled = true;
    }

    // 選択されていない状態に変更するとき
    void ChangeNoSelected(byte _num)
    {
        SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);
        Images[_num].noSelectedImage.enabled = true;
        Images[_num].selectedImage.enabled = false;
        Images[_num].backSelectedImage.enabled = false;
    }

    // イメージを格納する処理
    private TitleImages AddImages(byte _i)
    {
        var Trans = this.transform.GetChild(_i);
        TitleImages image;

        image.noSelectedImage = Trans.GetChild(0).GetComponent<Image>();
        image.backSelectedImage = Trans.GetChild(1).GetComponent<Image>();
        image.selectedImage = Trans.GetChild(2).GetComponent<Image>();

        image.backSelectedImage.enabled = false;
        image.selectedImage.enabled = false;

        return image;
    }

    private void CheckSceneCount()
    {
        int sceneCount = SceneManager.sceneCount;
        isInputSceneCount = sceneCount <= 1;
        Debug.Log(isInputSceneCount);
    }

    // ゲーム終了
    void GameEnd()
    {
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;//ゲームプレイ終了
#else
    Application.Quit();//ゲームプレイ終了
#endif
    }

    // リストを解放する処理
    private void OnApplicationQuit()
    {
        Images.Clear();
    }
}
