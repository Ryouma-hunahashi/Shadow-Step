using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

using UnityEngine.SceneManagement;
using UnityEngine.UI;


[System.Serializable]
public struct MapImage
{
    public Image image;         // Image格納用
    public Animator animator;   // ImageのAnimator格納用
    public Vector3 transPos;    // Imageのposition格納用
}

[System.Serializable]
public struct SelecterImage
{
    public Image image;         // Image格納用
    public Animator animator;   // ImageのAnimator格納用
    public Vector3 transPos;    // Imageのposition格納用
}

[System.Serializable]
public struct SelectImage
{
    public Image noSelectedImage;   // no selected 
    public Image backSelectedImage; // back selected
    public Image selectedImage;     // selected
}

public class StageSelecter : MonoBehaviour
{
    // 選択位置の情報
    public byte worldNum = 1;
    public byte stageNum = 0;

    // マップ情報
    public List<Stage_Manager.WorldInfo> mapInfo;

    // 位置変更速度の設定
    //[SerializeField] private byte selectDelayTime = 20;
    [SerializeField] private float zoomSpeed = 30.0f;
    //private bool nowDelayTime;  // 待機状態

    [Header("一つ前のシーンの名前")]
    [Tooltip("ズームしていない状態で東ボタンを押すとシーン遷移")]
    [SerializeField] private string backSceneName = "";


    // このオブジェのRectTransform格納用
    private RectTransform canvasTransform = null;

    // セレクトのImageの情報
    [SerializeField] private List<MapImage> mapImages = new List<MapImage>();
    [SerializeField] private List<SelecterImage> selecterImages = new List<SelecterImage>();

    // セレクトのImageの情報
    [SerializeField] private List<SelectImage> worldImages = new List<SelectImage>();
    [SerializeField] private List<SelectImage> selectImages = new List<SelectImage>();

    // 入力系統変数
    ControlManager controlManager;
    [SerializeField] private ControllerStickMover controllerStickMover = new ControllerStickMover();
    private float inputVel = 0.0f;

    // カメラオオブジェクト
    [SerializeField] private Camera cameraObj = null;

    // ロードスクリプト
    [SerializeField] private UI_Load loader;

    // アニメーション
    [SerializeField] private Animator stageAnim;


    private Vector3 defaultCameraPos;

    private bool cameraZoomFlag = false;
    private bool nowZoomOut = false;
    private bool nowStage = false;
    private bool isChanged = false;
    private bool isCheck = false;
    private bool scenechangeSet = false;

    [SerializeField] private AnimationCurve fadeOutCurve;
    [SerializeField] private Image fadeOutImage;
    private float elapsedTime;
    [SerializeField] private float fadeOutTime = 1.0f;
    private bool nowfadeOut = false;
    Image stageSettingImage;

    private bool isInputSceneCount = true;

    [SerializeField, PersistentAmongPlayMode]
    private Vector3 moveStageSelecter;

    [SerializeField] private Color defaultColor;
    [SerializeField] private Color selectColor;

    IEnumerator flameCol()
    {
        for (int i = 0; i < 10; i++)
        {
            yield return null;
        }

        stageAnim.SetBool("isSelected", true);

    }

    // Start is called before the first frame update
    void Start()
    {
        // データを送る
        mapInfo = Stage_Manager.instance.worldInformation;
        
        controlManager = GetComponent<ControlManager>();
        
        loader = loader.GetComponent<UI_Load>();
        
        // 最初のステージ情報を指定しておく
        worldNum = 1;
        stageNum = 0;
        
        // 子オブジェクトの数を取得
        byte childCnt = (byte)this.transform.childCount;
        
        canvasTransform = GetComponent<RectTransform>();
        if(canvasTransform == null) { Debug.LogError("RectTransformがコンポーネントされていません。"); }
        
        cameraObj = cameraObj.GetComponent<Camera>();
        if (cameraObj == null) { Debug.LogError("カメラが見つかりません"); }

        stageAnim = GetComponent<Animator>();
        if(stageAnim == null) { Debug.Log("Animatorが見つかりません"); }

        for (byte i = 0; i < this.transform.GetChild(0).childCount; i++) { worldImages.Add(AddImage(0, i)); }
        for (byte i = 0; i < this.transform.GetChild(1).childCount; i++) { selectImages.Add(AddImage(1, i)); }

        ChangeSelected(worldNum, 10);
        stageAnim.SetBool("isSelected", true);

        fadeOutImage = cameraObj.transform.GetChild(1).GetChild(0).GetComponent<Image>();

        controllerStickMover.Start();
        controllerStickMover.SetStickType(ControllerStickMover.STICK_MOVE_TYPE.STICK_VERTICAL);

        SoundManager.Get().SetBlendTrans(0);
        SoundManager.Get().ChangeGroupBGM(E_BGM_TYPE.TITLE, SoundManager.E_BGM_STATE.DEFAUL);
        SoundManager.Get().PlayBGM();
        //for(byte i = 0; i < childCnt; i++)
        //{
        //    // リストに格納する
        //    mapImages.Add(SetImage(i));
        //}
        //
        //// リスト内にカメラのオブジェクトを格納する
        //for(byte i = 0; i < cameraObj.transform.GetChild(0).childCount; i++)
        //{
        //    selecterImages.Add(SetSelectImage(i));
        //}
        //
        //// カメラ座標を代入
        //if(defaultCameraPos == null)
        //{
        //    defaultCameraPos = cameraObj.transform.position;
        //}
        //
        //fadeOutImage = cameraObj.transform.GetChild(1).GetChild(0).GetComponent<Image>();
        //
        //// 分かりやすいように現在のステージの色を替えておく
        //mapImages[worldNum].image.color = selectColor;
        //
        //controllerStickMover.Start();
        //controllerStickMover.SetStickType(ControllerStickMover.STICK_MOVE_TYPE.STICK_HORIZONTAL);

    }

    void FixedUpdate()
    {

        CheckSceneCount();

        if (isInputSceneCount)
        {
            // 縦の入力を取得
            inputVel = controllerStickMover.GetMoveNum();
            // 位置変更
            if (inputVel != 0 && !nowfadeOut) { ChangeVelStageNum(inputVel); }

            // A押されたら実行
            if ((controlManager.GetVariousInput(ControlManager.E_TYPE.PRESSED, ControlManager.E_GP.A) || controlManager.GetVariousInput(ControlManager.E_TYPE.PRESSED, ControlManager.E_KB.ENTER)) && !nowfadeOut)
            {
                if (worldNum == 0)
                {
                    nowfadeOut = true;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);

                    return;
                }
                if (nowStage)
                {
                    nowfadeOut = true;
                    nowStage = false;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);
                }
                if (!nowStage && !nowfadeOut)
                {
                    nowStage = true;
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_OK);
                }

            }

            // B押されたら実行
            if (controlManager.GetVariousInput(ControlManager.E_TYPE.PRESSED, ControlManager.E_GP.B) || controlManager.GetVariousInput(ControlManager.E_TYPE.PRESSED, ControlManager.E_KB.SPACE))
            {
                if (isChanged)
                {
                    nowStage = false;
                    isChanged = false;
                    ChangeNotSelected(stageNum);
                    SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CANCEL);
                    return;
                    //stageAnim.SetBool("isSelected",false);
                }
            }

            if (nowStage && !isChanged)
            {
                // 変更する
                ChangeSelected(stageNum);

                isChanged = true;
            }


            if (nowfadeOut && !isCheck)
            {
                var color = fadeOutImage.color;
                color.a = fadeOutCurve.Evaluate(elapsedTime / fadeOutTime);
                fadeOutImage.color = color;

                elapsedTime += Time.deltaTime;
                if (elapsedTime >= fadeOutTime)
                {
                    elapsedTime = fadeOutTime;

                    if (fadeOutImage.color.a == 1)
                    {
                        Debug.Log((worldNum) + " - " + (stageNum + 1) + " に飛びますっ！");
                        Debug.Log(mapInfo[worldNum].stageInformation[stageNum].sceneName);
                        Stage_Manager.instance.SetWorldNum(worldNum);
                        Stage_Manager.instance.SetStageNum(stageNum);
                        loader.StartLoad(mapInfo[worldNum].stageInformation[stageNum].sceneName);
                        isCheck = true;
                    }

                }
            }
        }
    }

    void ChangeVelStageNum(float _InputVel)
    {
        // 上入力
        if (_InputVel > 0)
        {
            if (isChanged)
            {
                Debug.Log("上方向に移動します");
                // ステージ番号がそのステージの最大値未満であるとき
                if (stageNum < (byte)mapInfo[worldNum].stageInformation.Count - 1)
                {
                    if (!mapInfo[worldNum].stageInformation[stageNum].stageLock)
                    {
                        ChangeNotSelected(stageNum);

                        stageNum++;

                        ChangeSelected(stageNum);
                        SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);
                    }
                }
                else
                {
                    // ワールドが最大値未満のとき
                    if (worldNum < (byte)mapInfo.Count - 1)
                    {
                        if (!mapInfo[worldNum + 1].worldLock)
                        {
                            ChangeNotSelected(worldNum, stageNum);
                            stageAnim.SetBool("isSelected", false);
                            worldNum++;

                            stageNum = 0;

                            StartCoroutine(flameCol());
                            ChangeSelected(worldNum, stageNum);
                            SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);
                            Debug.Log((worldNum)+"-"+(stageNum));
                        }
                    }
                }
            }
            else
            {
                if (worldNum < (byte)mapInfo.Count - 1)
                {
                    if (!mapInfo[worldNum + 1].worldLock) 
                    {
                        ChangeNotSelected(worldNum, 10);
                        stageAnim.SetBool("isSelected", false);

                        worldNum++;

                        StartCoroutine(flameCol());
                        ChangeSelected(worldNum, 10);

                        SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

                        if (worldNum == 1) { stageAnim.SetBool("isSelected", true); }
                    }
                }
            }
        }
        // 下入力
        else if (_InputVel < 0)
        {
            Debug.Log("下方向に移動します");
            if (isChanged)
            {
                if (stageNum > 0)
                {
                    if (!mapInfo[worldNum].stageInformation[stageNum - 1].stageLock)
                    {
                        ChangeNotSelected(stageNum);

                        stageNum--;

                        ChangeSelected(stageNum);

                        SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

                    }
                }
                else
                {
                    if (worldNum != 0)
                    {
                        if (!mapInfo[worldNum - 1].worldLock)
                        {
                            stageAnim.SetBool("isSelected", false);
                            ChangeNotSelected(worldNum, stageNum);

                            worldNum--;
                            stageNum = (byte)(mapInfo[worldNum].stageInformation.Count - 1);

                            ChangeSelected(worldNum, stageNum);

                            SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);


                            if (worldNum == 0) 
                            { 
                                ChangeNotSelected(stageNum);
                                nowStage = false;
                                isChanged = false;
                                stageAnim.SetBool("isSelected", true);
                                return;
                            }
                            StartCoroutine(flameCol());
                            //stageAnim.SetBool("isSelected", true);
                        }
                    }
                }
            }
            else 
            {
                if(worldNum >0)
                {
                    if (!mapInfo[worldNum - 1].worldLock)
                    {
                        ChangeNotSelected(worldNum, 10);
                        if (worldNum - 1 != 0)
                        {
                            stageAnim.SetBool("isSelected", false);

                            worldNum--;

                            StartCoroutine(flameCol());

                            SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

                        }
                        else
                        {
                            worldNum--;
                            SoundManager.Get().PlayOneShotSE2D(E_SE_TYPE.UI_CURSOR_MOVE);

                        }
                        ChangeSelected(worldNum, 10);
                    }
                }
            }
        }
    }

    void ChangeHorizontalPosition(float _inputHorizontal)
    {
        // 左方向入力されたとき
        if(_inputHorizontal < 0)
        {
            Debug.Log("左方向へ移動します");
            // カメラがズーム状態の時
            if(cameraZoomFlag)
            {
                // ステージ番号が0より大きいとき
                if (stageNum > 0)
                {
                    // ひとつ前のステージがロックされていないとき
                    if (!mapInfo[worldNum].stageInformation[stageNum - 1].stageLock)
                    {
                        // カラーを通常カラーにする
                        selecterImages[GetImageNumber()].image.color = defaultColor;
                        // アニメーションをオフにする
                        selecterImages[GetImageNumber()].animator.SetBool("isSelect", false);
                        // ステージ番号を一つ下げる
                        stageNum--;
                        // 下げたステージ番号のアニメーションをオンにする
                        selecterImages[GetImageNumber()].animator.SetBool("isSelect", true);
                        // 下げたステージのカラーを選択カラーにする
                        selecterImages[GetImageNumber()].image.color = selectColor;
                    }
                }
                else
                {
                    // ワールド番号が0以外の時
                    if (worldNum != 0)
                    {
                        // ひとつ前のワールドがロックされていないとき
                        if (!mapInfo[worldNum - 1].worldLock)
                        {
                            // 今現在のワールドのステージ分アニメーションをオンにする
                            for (byte i = 0; i < mapInfo[worldNum].stageInformation.Count; i++)
                            {
                                selecterImages[GetImageNumber() - stageNum + i].animator.SetBool("isStage", false);
                            }
                            // ステージのアニメーションをオフにする
                            selecterImages[GetImageNumber()].animator.SetBool("isSelect", false);
                            // ワールド番号を通常カラーにする
                            mapImages[worldNum].image.color = defaultColor;
                            // ステージ番号の通常カラーにする
                            selecterImages[GetImageNumber()].image.color = defaultColor;
                            // ワールド番号を一つを下げる
                            worldNum--;
                            // ステージ番号を一つ下げる
                            stageNum = (byte)(mapInfo[worldNum].stageInformation.Count - 1);
                            // 今現在のワールドのステージ分アニメーションをオンにする
                            for(byte i=0;i<mapInfo[worldNum].stageInformation.Count;i++)
                            {
                                selecterImages[GetImageNumber() - stageNum + i].animator.SetBool("isStage", true);
                            }
                            // ステージのアニメーションをオンにする
                            selecterImages[GetImageNumber()].animator.SetBool("isSelect", true);
                            // ワールド番号を選択カラーにする
                            mapImages[worldNum].image.color = selectColor;
                            // ステージ番号を選択カラーにする
                            selecterImages[GetImageNumber()].image.color = selectColor;
                            // ステージ移動フラグをオンにする
                            scenechangeSet = true;
                            // カメラ移動をする
                            ZoomMove();
                        }
                    }
                }
            }
            else
            {
                Debug.Log("world移動左");
                // ワールド番号が0より大きいとき
                if(worldNum > 0)
                {
                    // ひとつ前のワールドがロックされていないとき
                    if (!mapInfo[worldNum - 1].worldLock)
                    {
                        // 選択カラーを通常カラーにする
                        mapImages[worldNum].image.color = defaultColor;
                        // ワールド番号を下げる
                        worldNum--;
                        // 通常カラーを選択カラーにする
                        mapImages[worldNum].image.color = selectColor;
                    }
                }
                // シーン移動フラグをオフにする
                scenechangeSet=false;
            }
        }
        // 右方向入力されたとき
        else if(_inputHorizontal > 0)
        {
            Debug.Log("右方向へ移動します");
            // ステージ選択されているとき
            if(cameraZoomFlag)
            {
                // ステージ番号が最大値未満の時
                if (stageNum < (byte)mapInfo[worldNum].stageInformation.Count - 1)
                {
                    // 次のワールド番号がロックされていないとき
                    if(!mapInfo[worldNum].stageInformation[stageNum+1].stageLock)
                    {
                        // ステージのアニメーションをオフにする
                        selecterImages[GetImageNumber()].animator.SetBool("isSelect", false);
                        // ステージ番号を通常カラーにする
                        selecterImages[GetImageNumber()].image.color = defaultColor;
                        // ステージ番号を一つ上げる
                        stageNum++;
                        // ステージのアニメーションをオンにする
                        selecterImages[GetImageNumber()].animator.SetBool("isSelect", true);
                        // ステージ番号を選択カラーにする
                        selecterImages[GetImageNumber()].image.color = selectColor;
                    }
                }
                else
                {
                    // ワールド番号が最大ではない時
                    if(worldNum < (byte)mapInfo.Count-1)
                    {
                        // 次のワールドがロックされていないとき
                        if(!mapInfo[worldNum+1].worldLock)
                        {
                            // 現在のワールド分のステージ番号のアニメーションをオフにする
                            for (byte i = 0; i < mapInfo[worldNum].stageInformation.Count; i++)
                            {
                                selecterImages[GetImageNumber() - stageNum + i].animator.SetBool("isStage", false);
                            }
                            // ワールド番号を通常カラーにする
                            mapImages[worldNum].image.color = defaultColor;
                            // ステージ番号のアニメーションをオフにする
                            selecterImages[GetImageNumber()].animator.SetBool("isSelect", false);
                            // ステージ番号を通常カラーにする
                            selecterImages[GetImageNumber()].image.color = defaultColor;
                            // ワールド番号を一つ上げる
                            worldNum++;
                            // ステージ番号をリセットする
                            stageNum = 0;
                            // 現在のワールド分のステージ番号のアニメーションをオンにする
                            for (byte i = 0; i < mapInfo[worldNum].stageInformation.Count; i++)
                            {
                                selecterImages[GetImageNumber() - stageNum + i].animator.SetBool("isStage", true);
                            }
                            // ステージ番号のアニメーションをオンにする
                            selecterImages[GetImageNumber()].animator.SetBool("isSelect", true);
                            // ワールド番号を選択カラーにする
                            mapImages[worldNum].image.color = selectColor;
                            // ステージ番号を選択カラーにする
                            selecterImages[GetImageNumber()].image.color = selectColor;
                            // ステージ移動フラグをオンにする
                            scenechangeSet = true;
                            // カメラ移動する
                            ZoomMove();
                        }
                    }
                }
            }
            else
            {
                // ワールド番号が最大値でないとき
                if(worldNum < (byte)mapInfo.Count - 1)
                {
                    // 次のワールド番号がロックされていないとき
                    if(!mapInfo[worldNum+1].worldLock)
                    {
                        // ワールド番号を通常カラーにする
                        mapImages[worldNum].image.color = defaultColor;
                        // ワールド番号を一つ上げる
                        worldNum++;
                        // ワールド番号を選択カラーにする
                        mapImages[worldNum].image.color = selectColor;
                    }
                }
                // シーン移動フラグをオフにする
                scenechangeSet = false;
            }
        }
    }

    void ZoomMove()
    {
        switch (mapInfo[worldNum].zoomSet)
        {
            case Stage_Manager.WorldInfo.ZoomSet.ON:
                // 現在位置を変更する
                if (cameraZoomFlag)
                {
                    nowStage = true;
                }
                break;
            case Stage_Manager.WorldInfo.ZoomSet.OFF:
                if (cameraZoomFlag)
                {
                    nowZoomOut = true;
                    cameraZoomFlag = false;
                }
                break;
        }
    }

    private void ChangeSelected(byte _num)
    {
        selectImages[_num].noSelectedImage.enabled = false;
        selectImages[_num].backSelectedImage.enabled = true;
        selectImages[_num].selectedImage.enabled = true;
    }

    private void ChangeSelected(byte _worldnum, byte _stagenum)
    {
        worldImages[worldNum].selectedImage.enabled = true;
        worldImages[worldNum].backSelectedImage.enabled = true;
        worldImages[worldNum].noSelectedImage.enabled = false;
        //Debug.Log((stageNum) + "" + mapImages.Count);
        if (_stagenum < selectImages.Count)
        {
            selectImages[_stagenum].noSelectedImage.enabled = false;
            selectImages[_stagenum].backSelectedImage.enabled = true;
            selectImages[_stagenum].selectedImage.enabled = true;
        }
    }

    private void ChangeNotSelected(byte _num)
    {
        selectImages[_num].noSelectedImage.enabled = true;
        selectImages[_num].backSelectedImage.enabled = false;
        selectImages[_num].selectedImage.enabled = false;

    }

    private void ChangeNotSelected(byte _worldnum, byte _stagenum)
    {
        worldImages[_worldnum].selectedImage.enabled = false;
        worldImages[_worldnum].backSelectedImage.enabled= false;
        worldImages[_worldnum].noSelectedImage.enabled = true;

        if (_stagenum < selectImages.Count)
        {
            selectImages[_stagenum].noSelectedImage.enabled = true;
            selectImages[_stagenum].backSelectedImage.enabled = false;
            selectImages[_stagenum].selectedImage.enabled = false;
        }
    }

    private byte GetImageNumber()
    {
        byte stageCount = 0;

        // ワールド内に存在するステージをひとつ前のワールドまで加算
        for (byte i = 0; i < worldNum; i++)
        {
            stageCount += (byte)mapInfo[i].stageInformation.Count;
        }
        // 現在のステージ番号を加算することでImageの番号を決定
        stageCount += stageNum;

        return stageCount;
    }

    private void CheckSceneCount()
    {
        int sceneCount = SceneManager.sceneCount;
        isInputSceneCount = sceneCount <= 1;
        Debug.Log(isInputSceneCount);
    }

    private SelectImage AddImage(byte _i , byte _num)
    {
        var trans = this.transform.GetChild(_i);

        SelectImage image;

        image.backSelectedImage = trans.GetChild(_num).GetChild(0).GetComponent<Image>();
        image.selectedImage = trans.GetChild(_num).GetChild(1).GetComponent<Image>();
        image.noSelectedImage = trans.GetChild(_num).GetChild(2).GetComponent<Image>();

        image.backSelectedImage.enabled = false;
        image.selectedImage.enabled = false;

        return image;
    }

    private MapImage SetImage(byte _i)
    {
        var trans = transform.GetChild(_i);

        MapImage image;
        image.image = trans.GetComponent<Image>();
        image.animator = trans.GetComponent<Animator>();
        image.transPos = trans.GetComponent<RectTransform>().position;
        image.transPos.y = 0;

        

        return image;
    }

    private SelecterImage SetSelectImage(byte _i)
    {
        var trans = cameraObj.transform.GetChild(0).GetChild(_i);
        SelecterImage image;

        image.image = trans.GetComponent<Image>();
        image.animator = trans.GetComponent<Animator>();
        image.transPos = trans.GetComponent<RectTransform>().position;


        return image;
    }
}
