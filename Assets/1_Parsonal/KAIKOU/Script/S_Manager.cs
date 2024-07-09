using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;

public class S_Manager : MonoBehaviour
{
    public enum E_SYSTEM_SCENE
    {
        SCENE_TITLE,
        SCENE_SELECT,
        SCENE_RESULT,

    }
    
    [System.Serializable]
    public struct S_SCENE_DATA
    {
        public E_SYSTEM_SCENE scene;
        public string name;
    }

    // ワールド情報の設定
    [System.Serializable]
    public class WorldInfo
    {
        // ワールド情報
        [Tooltip("地図片の名前")]
        public string worldName;
        [Tooltip("ワールドの開放状況")]
        public bool worldLock;
        public bool worldLockLog;
        // ステージ情報のクラスを取得
        [Tooltip("ステージの情報")]
        public List<StageInfo> stageInformation = new List<StageInfo>();
    }

    // ステージ情報の設定
    [System.Serializable]
    public class StageInfo
    {
        // パフェの所持状態
        [System.Serializable]
        public struct parfaitInfo
        {
            public bool top;    // 上層
            public bool mid;    // 中層
            public bool btm;    // 下層
        }

        // ステージ情報
        [Tooltip("ステージの名前")]
        public string stageName;
        [Tooltip("シーンの名前")]
        public string sceneName;
        [Tooltip("ステージのクリア情報")]
        public bool clearFg = false;
        [Tooltip("ステージのロック情報")]
        public bool stageLock = false;

        // 収集アイテムの状況
        //[Tooltip("パフェの所持状況")]
        //public parfaitInfo parfait;



    }

    public static S_Manager instance;

    public List<S_SCENE_DATA> scenes = new List<S_SCENE_DATA>();
    // ステージ情報の設定
    public List<WorldInfo> worldInformation = new List<WorldInfo>();

    private void Awake()
    {
        // シングルトンの作成
        // 存在しなければこのオブジェクトを保存
        if(instance == null)
        {
            instance = this;
            DontDestroyOnLoad(this.gameObject);
        }
        // 存在すれば破壊
        else
        {
            Destroy(this.gameObject);
        }
    }

    void Start()
    {
        
    }

    void Update()
    {
    }

    private void LoadScene(string _sceneName)
    {


        SceneManager.LoadScene(_sceneName);

    }

    public void LoadScene(E_SYSTEM_SCENE _scene)
    {
        foreach(S_SCENE_DATA sceneData in scenes)
        {
            if(sceneData.scene == _scene)
            {
                LoadScene(sceneData.name);
                break;
            }
        }
    }

    public void LoadStage(int worldNum,int stageNum)
    {
        LoadScene(worldInformation[worldNum].stageInformation[stageNum].sceneName);
    }

    public void SceneChange(string sceneName)
    {
        // シーンを入れ替える
        SceneManager.LoadScene(sceneName);
    }
}
