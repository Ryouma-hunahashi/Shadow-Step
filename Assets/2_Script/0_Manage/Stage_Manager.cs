using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//========================================
//          ステージの情報
//========================================
public class Stage_Manager : MonoBehaviour
{
    // シングルトンの作成
    public static Stage_Manager instance;

    private void Awake()
    {
        
        // 自身が存在していないなら
        if(instance == null)
        {
            // 自身をインスタンス化
            instance = this;

            // シーン変更時に破棄されないようにする
            DontDestroyOnLoad(this.gameObject);
        }
        else
        {
            // すでに自身が存在しているなら破棄
            Destroy(this.gameObject);

        }

        // ワールドロックのログを格納する
        for (byte i = 0; i < worldInformation.Count; i++)
        {
            worldInformation[i].worldLockLog = worldInformation[i].worldLock;
        }
    }

    // ワールド情報の設定
    [System.Serializable]
    public class WorldInfo
    {

        // ズームの設定
        public enum ZoomSet
        {
            ON,
            OFF,
        }
        // ワールド情報
        [Tooltip("地図片の名前")]
        public string worldName;
        [Tooltip("ワールドの開放状況")]
        public bool worldLock;
        public bool worldLockLog;
        // ステージ情報のクラスを取得
        [Tooltip("ステージの情報")]
        public List<StageInfo> stageInformation = new List<StageInfo>();
        [Tooltip("対応するImageにズームを行う")]
        public ZoomSet zoomSet;
        // カメラ情報
        [Tooltip("カメラを固定する座標\n" + "Imageからの相対座標")]
        public Vector3 cameraZoomPos;
    }

    // ステージ情報の設定
    [System.Serializable]
    public class StageInfo
    {
        // ステージ情報
        [Tooltip("ステージの名前")]
        public string stageName;
        [Tooltip("シーンの名前")]
        public string sceneName;
        [Tooltip("ステージのロック情報")]
        public bool stageLock = false;
    }

    // インスペクターに表示 -----
    // 地図情報の設定
    public List<WorldInfo> worldInformation = new List<WorldInfo>();

    public string StageselectName = "";
    private byte worldNum;
    private byte stageNum;

    public byte GetWorldNum() { return worldNum; }
    public byte GetStageNum() { return stageNum; }

    public void SetWorldNum(byte _num) { worldNum = _num; }
    public void SetStageNum(byte _num) { stageNum = _num; }

    // リスト解放処理
    private void OnApplicationQuit()
    {
        worldInformation.Clear();
    }
}