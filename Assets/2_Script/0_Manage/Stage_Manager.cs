using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//========================================
//          �X�e�[�W�̏��
//========================================
public class Stage_Manager : MonoBehaviour
{
    // �V���O���g���̍쐬
    public static Stage_Manager instance;

    private void Awake()
    {
        
        // ���g�����݂��Ă��Ȃ��Ȃ�
        if(instance == null)
        {
            // ���g���C���X�^���X��
            instance = this;

            // �V�[���ύX���ɔj������Ȃ��悤�ɂ���
            DontDestroyOnLoad(this.gameObject);
        }
        else
        {
            // ���łɎ��g�����݂��Ă���Ȃ�j��
            Destroy(this.gameObject);

        }

        // ���[���h���b�N�̃��O���i�[����
        for (byte i = 0; i < worldInformation.Count; i++)
        {
            worldInformation[i].worldLockLog = worldInformation[i].worldLock;
        }
    }

    // ���[���h���̐ݒ�
    [System.Serializable]
    public class WorldInfo
    {

        // �Y�[���̐ݒ�
        public enum ZoomSet
        {
            ON,
            OFF,
        }
        // ���[���h���
        [Tooltip("�n�}�Ђ̖��O")]
        public string worldName;
        [Tooltip("���[���h�̊J����")]
        public bool worldLock;
        public bool worldLockLog;
        // �X�e�[�W���̃N���X���擾
        [Tooltip("�X�e�[�W�̏��")]
        public List<StageInfo> stageInformation = new List<StageInfo>();
        [Tooltip("�Ή�����Image�ɃY�[�����s��")]
        public ZoomSet zoomSet;
        // �J�������
        [Tooltip("�J�������Œ肷����W\n" + "Image����̑��΍��W")]
        public Vector3 cameraZoomPos;
    }

    // �X�e�[�W���̐ݒ�
    [System.Serializable]
    public class StageInfo
    {
        // �X�e�[�W���
        [Tooltip("�X�e�[�W�̖��O")]
        public string stageName;
        [Tooltip("�V�[���̖��O")]
        public string sceneName;
        [Tooltip("�X�e�[�W�̃��b�N���")]
        public bool stageLock = false;
    }

    // �C���X�y�N�^�[�ɕ\�� -----
    // �n�}���̐ݒ�
    public List<WorldInfo> worldInformation = new List<WorldInfo>();

    public string StageselectName = "";
    private byte worldNum;
    private byte stageNum;

    public byte GetWorldNum() { return worldNum; }
    public byte GetStageNum() { return stageNum; }

    public void SetWorldNum(byte _num) { worldNum = _num; }
    public void SetStageNum(byte _num) { stageNum = _num; }

    // ���X�g�������
    private void OnApplicationQuit()
    {
        worldInformation.Clear();
    }
}