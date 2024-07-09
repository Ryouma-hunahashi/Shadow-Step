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

    // ���[���h���̐ݒ�
    [System.Serializable]
    public class WorldInfo
    {
        // ���[���h���
        [Tooltip("�n�}�Ђ̖��O")]
        public string worldName;
        [Tooltip("���[���h�̊J����")]
        public bool worldLock;
        public bool worldLockLog;
        // �X�e�[�W���̃N���X���擾
        [Tooltip("�X�e�[�W�̏��")]
        public List<StageInfo> stageInformation = new List<StageInfo>();
    }

    // �X�e�[�W���̐ݒ�
    [System.Serializable]
    public class StageInfo
    {
        // �p�t�F�̏������
        [System.Serializable]
        public struct parfaitInfo
        {
            public bool top;    // ��w
            public bool mid;    // ���w
            public bool btm;    // ���w
        }

        // �X�e�[�W���
        [Tooltip("�X�e�[�W�̖��O")]
        public string stageName;
        [Tooltip("�V�[���̖��O")]
        public string sceneName;
        [Tooltip("�X�e�[�W�̃N���A���")]
        public bool clearFg = false;
        [Tooltip("�X�e�[�W�̃��b�N���")]
        public bool stageLock = false;

        // ���W�A�C�e���̏�
        //[Tooltip("�p�t�F�̏�����")]
        //public parfaitInfo parfait;



    }

    public static S_Manager instance;

    public List<S_SCENE_DATA> scenes = new List<S_SCENE_DATA>();
    // �X�e�[�W���̐ݒ�
    public List<WorldInfo> worldInformation = new List<WorldInfo>();

    private void Awake()
    {
        // �V���O���g���̍쐬
        // ���݂��Ȃ���΂��̃I�u�W�F�N�g��ۑ�
        if(instance == null)
        {
            instance = this;
            DontDestroyOnLoad(this.gameObject);
        }
        // ���݂���Δj��
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
        // �V�[�������ւ���
        SceneManager.LoadScene(sceneName);
    }
}
