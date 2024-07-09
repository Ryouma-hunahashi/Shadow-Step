using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class VFX_FuseFire : MonoBehaviour
{
    [System.Serializable]
    public struct FIRE_LIST
    {
        public Transform mainTrans; // ��{��Transform
        public List<VisualEffect> effects; // �G�t�F�N�g���X�g
    }

    private enum E_FIRE_MODE
    { 
        OUT,    // �������
        NORMAL, // �ʏ���
        UP,     // �������
    }


    // ���Α��u�̏�ԊǗ��p(�t���Ă��邩�����Ă��邩)
    private FuseConditioner fuseCon;
    // �e�ւ̘A�����m�F����p(������Ԃ��ǂ���)
    private PlayerShadowMode shadowMode;

    // ���̏��
    E_FIRE_MODE fireMode = E_FIRE_MODE.NORMAL;

    [Header("�ʏ퉊�̃G�t�F�N�g���X�g")]
    [SerializeField] private FIRE_LIST normalFire;
    [Header("�������̃G�t�F�N�g���X�g")]
    [SerializeField] private FIRE_LIST powerUpFire;
    [Header("�|�C���g���C�g")]
    [SerializeField] private GameObject light;

    // �����邩�ǂ���
    private bool dieable = false;




    // Start is called before the first frame update
    void Start()
    {
        // ��ԊǗ��X�N���v�g�擾
        fuseCon = transform.parent.GetComponent<FuseConditioner>();
        // ���̉��������邩�ǂ����𔻒f�B
        dieable = fuseCon != null;
        // �e�ւ̘A���Ǘ��X�N���v�g�擾
        GameObject[] objs = GameObject.FindGameObjectsWithTag("Player");
        shadowMode = objs[objs.Length-1].GetComponent<PlayerShadowMode>();

        // ���̃I�u�W�F�N�g�̉��G�t�F�N�g���擾
        Transform normalPar = transform.GetChild(1);
        normalPar.gameObject.SetActive(false);
        normalFire.mainTrans = normalPar;
        SetFireEffect(normalPar, normalFire.effects);

        // ���̃I�u�W�F�N�g�̋������G�t�F�N�g���擾
        Transform powerPar = transform.GetChild(2);
        powerPar.gameObject.SetActive(false);
        powerUpFire.mainTrans = powerPar;
        SetFireEffect(powerPar, powerUpFire.effects);

        // ���̃I�u�W�F�N�g�̃|�C���g���C�g���擾
        light = transform.GetChild(0).gameObject;


        light.SetActive(false);
        if (!dieable || fuseCon.active)
        {
            light.SetActive(true);
            StartFire(ref normalFire);
        }

    }

    // Update is called once per frame
    void Update()
    {
        FireSwitch();
    }

    private void FireSwitch()
    {
        switch(fireMode)
        {
            case E_FIRE_MODE.OUT:
                Switch_ForOut();
                break;
            case E_FIRE_MODE.NORMAL:
                Switch_ForNormal();
                break;
            case E_FIRE_MODE.UP:
                Switch_ForUp();
                break;
        }

    }

    private void Switch_ForOut()
    {
        if(fuseCon.active)
        {
            light.SetActive(true);
            StartFire(ref normalFire);
            fireMode = E_FIRE_MODE.NORMAL;
        }
    }

    private void Switch_ForNormal()
    {
        if(shadowMode.goFire)
        {
            EndFire(ref normalFire);
            StartFire(ref powerUpFire);
            fireMode = E_FIRE_MODE.UP;
        }
    }

    private void Switch_ForUp()
    {
        if (!shadowMode.goFire)
        {
            if (dieable&&!fuseCon.active)
            {
                EndFire(ref powerUpFire);
                EndFire(ref normalFire);
                light.SetActive(false);
                fireMode = E_FIRE_MODE.OUT;
            }
            else
            {
                EndFire(ref powerUpFire);
                StartFire(ref normalFire);
                fireMode= E_FIRE_MODE.NORMAL;
            }
        }
    }


    public void StartFire(ref FIRE_LIST _fire)
    {
        _fire.mainTrans.gameObject.SetActive(true);
        for(int i = 0; i < _fire.effects.Count; i++)
        {
            _fire.effects[i].SendEvent("Play");
        }
    }

    public void EndFire(ref FIRE_LIST _fire)
    {
        _fire.mainTrans.gameObject.SetActive(false);
        //for (int i = 0; i < _fire.effects.Count; i++)
        //{
        //    _fire.effects[i].SendEvent("");
        //}
    }

    /// <summary>
    /// ���G�t�F�N�g�����X�g�ɓo�^����
    /// </summary>
    /// <param name="_grandPar">�o�^�������G�t�F�N�g��Z�߂��I�u�W�F��Transform</param>
    /// <param name="_effects">�o�^��VisualEffect���X�g</param>
    public void SetFireEffect(Transform _grandPar,List<VisualEffect> _effects)
    {
        // �q�̐��J��Ԃ�
        for (int i = 0; i < _grandPar.childCount; i++)
        {
            // i�Ԗڂ̎q��o�^
            Transform oneFirePar = _grandPar.GetChild(i);
            // oneFirePar�̎q��VisualEffect��o�^
            for (int j = 0; j < oneFirePar.childCount; j++)
            {
                _effects.Add(oneFirePar.GetChild(j).GetComponent<VisualEffect>());
            }
        }
    }

    private void OnApplicationQuit()
    {
        normalFire.effects.Clear();
        powerUpFire.effects.Clear();
    }
}
