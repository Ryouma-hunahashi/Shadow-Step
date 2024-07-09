using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireController : MonoBehaviour
{
    public enum FIRE_STATE
    {
        NOFIRE,         // �R���Ă��Ȃ��Ƃ�
        IN_OUT_FIRE,    // ������O�֔R���Ă���Ƃ�
        OUT_IN_FIRE     // �O���璆�֔R���Ă���Ƃ�
    }
    [SerializeField]private FIRE_STATE fireState = FIRE_STATE.NOFIRE;

    private int fireRoadTime = 5;
    private double oneFireElapTime = 0.0f; // ��̉��ɂ�����o�ߎ���
    private double fireElapTime = 0.0f; // �S�̂̌o�ߎ���
    public int GetFireRemain() { return fireRoadTime; } // �c�莞��
    private int fireRoadNum = 0; // ���݂����Ă���Œ�l
    public int GetFireRoad() { return fireRoadNum; }
    private double oneShadowFireTime = 0; // ��̉e�̂����鎞��
    private float accelCheckTime;
    private bool fireSet = false;
    public bool GetFireSet() { return fireSet; }
    public bool GetFire() { return FIRE_STATE.OUT_IN_FIRE == fireState; }
    public FIRE_STATE GetFireState() { return fireState; }
    public void SetFireState(FIRE_STATE _setState) { fireState = _setState; }

    private bool SetItO = false;

    public ShadowManager manager;

    public bool powerUp = false;
    private bool fireStop = false;
    public void StopFire(int _stopNum)
    {
        fireRoadNum = _stopNum;
        fireStop = true; 
    }


    public void ResetFireData()
    {
        fireState = FIRE_STATE.NOFIRE;
        oneFireElapTime = 0.0f;
        fireRoadNum = 0;
        oneShadowFireTime = 0.0f;
        accelCheckTime = 0.0f;
        fireStop = false;
        fireSet = false;
        SetItO = false;
        powerUp = false;
        Debug.Log("�e�͂��ȂȂ�");
    }

    void Update()
    {
        // �U�����s��Ԃł����
        if (!fireSet && manager.shadowModeSqript.goFire && manager.mainSqript.GetExtendFg()
            && transform == manager.mainSqript.extendObj.transform.parent)
        {
            fireSet = true;
            //manager.shadowModeSqript.goFire = false;
            // �e�̒��΂��Z�b�g
            FireSetting();
        }
        // �e��R�₷����
        FireUpdate();
        // �e�A������
        ChainUpdate();
    }

    // �e�ւ̒��΂�ݒ�i�Ōォ��j
    public void FireSetting()
    {
        // �v���C���[�̔R�₷���Ԃ��擾
        fireRoadTime = manager.shadowModeSqript.initSpeed;
        // ���ΊJ�n�I�u�W�F�N�g�̎q�I�u�W�F�N�g�ԍ����擾
        fireRoadNum = manager.hitchild.transform.parent.childCount;
        // �R�₷���Ԃ��I�u�W�F�N�g�ԍ��ŏ��Z����̔��Ύ��Ԃ��v�Z
        oneShadowFireTime = 1.0 / manager.shadowModeSqript.initSpeed;
        // �o�ߎ��ԓ�������
        oneFireElapTime = 0;
        // �O������ɔR�₷��Ԃɂ���
        fireState = FIRE_STATE.OUT_IN_FIRE;
        //nowFire = true;
    }

    // �e�ւ̒��΂�ݒ�i�擪����jtest
    public void FireFirstSetting(int _initSpd,bool _powerUp)
    {
        if (fireSet) { return; }
        // �v���C���[�̔R�₷���Ԃ��擾
        fireRoadTime = _initSpd;
        // ���ΊJ�n�I�u�W�F�N�g�̎q�I�u�W�F�N�g�ԍ����擾(�擪 0)
        fireRoadNum = 0;
        // �R�₷���Ԃ��e�̌����ŏ��Z���Ē��Ύ��Ԃ��v�Z
        oneShadowFireTime = 1.0 / manager.shadowModeSqript.initSpeed;
        // �o�ߎ��Ԃ�������
        oneFireElapTime = 0;
        // ������O�ɔR�₷��Ԃɂ���
        SetFireState(FIRE_STATE.IN_OUT_FIRE);
        powerUp = _powerUp;
        if(powerUp)
        {
            manager.barrirBreak = true;
        }
        fireState = FIRE_STATE.IN_OUT_FIRE;
        fireSet = true;
    }

    /// <summary>
    /// �e����̘A����ݒ�
    /// </summary>
    /// <param name="_remainTime">�c��̔��Ύ���</param>
    /// <param name="_startNum">�A�������e�R���C�_�[�̎q�ԍ�</param>
    public void ChainSetting(int _initSpd, int _startNum, bool _powerUp)
    {
        // �c�蔭�Ύ��Ԏ擾
        fireRoadTime = _initSpd;
        // �q�ԍ��擾
        fireRoadNum = _startNum;
        // �������̔��Ύ��Ԏ擾
        oneShadowFireTime = 1 / (double)fireRoadTime;
        // �o�ߎ��ԓ�������
        oneFireElapTime = 0;
        fireSet = true;
        powerUp = _powerUp;
        if (powerUp)
        {
            manager.barrirBreak = true;
        }
        fireState =FIRE_STATE.OUT_IN_FIRE;
    }

    /// <summary>
    /// ���΂̍X�V����
    /// </summary>
    private void FireUpdate()
    {
        if(fireState != FIRE_STATE.OUT_IN_FIRE) { return; }
        if (manager.fireEnd) { return; }
        if (fireStop) { return; }
        if (!SetItO&&fireRoadNum <= 0)
        {
            // �����ʕ����ɉe���L�тĂ���΁A�G���������ɉe��R�₷
            bool bf = false;
            for (int i = 0; i < 4; i++)
            {
                
                // �������Q�Ƃ��Ă���Ύ��̔ԍ��Ɉړ�����
                if(i == transform.GetSiblingIndex()) { continue; }
                
                // �ʕ����ɉe���L�тĂ����
                if (this.transform.parent.GetChild(i).childCount != 0)
                {
                    if (!manager.mainSqript.GetFireCon(i).GetFireSet())
                    {

                        manager.mainSqript.GetFireCon(i).FireFirstSetting(fireRoadTime,powerUp);
                        bf = true;
                    }
                }
            }
            if(!bf)
            {
                Debug.Log("�A���ł��˂��̂Ŏ���");
                manager.fireEnd = true;
            }
            SetItO = true;
            manager.enemyFlame = true;

            // �������Z�b�g
        }

        // ���ԍX�V
        oneFireElapTime += Time.deltaTime;
        fireElapTime += Time.deltaTime;
        accelCheckTime += Time.deltaTime;

        if(accelCheckTime > PlayerShadowMode.accelTime)
        {
            fireRoadTime+=manager.shadowModeSqript.accel;
            oneShadowFireTime = 1.0 / fireRoadTime;
            accelCheckTime = 0;
        }
        // ��̌o�ߎ��Ԃ𒴂����
        if (oneFireElapTime >= oneShadowFireTime)
        {
            // ���߂��������v�Z
            int overNum = (int)(oneFireElapTime / oneShadowFireTime);

            oneFireElapTime = oneFireElapTime - oneShadowFireTime * overNum;
            // ���߂��������[�h�����}�C�i�X����
            fireRoadNum -= overNum;
        }

    }

    // �A���̍X�V����
    private void ChainUpdate()
    {
        // �R���Ă��Ȃ���Δ�����
        //if(!nowFire) { return; }
        if(fireState != FIRE_STATE.IN_OUT_FIRE) { return; }

        if(fireRoadNum >= this.transform.childCount)
        {
            Debug.Log("��܂ŔR�����̂Ŏ���");
            manager.fireEnd = true;
        }

        // ���ԍX�V
        oneFireElapTime += Time.deltaTime;
        fireElapTime += Time.deltaTime;
        accelCheckTime += Time.deltaTime;

        if (accelCheckTime > PlayerShadowMode.accelTime)
        {
            fireRoadTime += manager.shadowModeSqript.accel;
            oneShadowFireTime = 1.0 / fireRoadTime;
            accelCheckTime = 0;
        }
        // ��̌o�ߎ��Ԃ𒴂����
        if (oneFireElapTime >= oneShadowFireTime)
        {
            // ���߂��������v�Z
            int overNum = (int)(oneFireElapTime / oneShadowFireTime);
            oneFireElapTime = oneFireElapTime - oneShadowFireTime * overNum;
            // ���߂��������[�h�����v���X����
            fireRoadNum += overNum;
        }
    }
}
