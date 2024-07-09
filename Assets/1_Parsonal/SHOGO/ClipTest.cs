using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClipTest : MonoBehaviour
{
    private Material m_Material;
    private GameObject m_PlayeObject;
    [SerializeField] float m_drawRange=10;
    // Start is called before the first frame update
    void Start()
    {
        // Material�̎擾
        m_Material =GetComponent<MeshRenderer>().material;
        if(m_Material == null)
        {
            Debug.Log("Material�����݂��܂���");
        }
        // �v���C���[�I�u�W�F�N�g�̎擾
        m_PlayeObject = GameObject.FindWithTag("Player");
        if(m_PlayeObject == null)
        {
            Debug.LogError("�v���C���[�I�u�W�F�N�g�����݂��܂���");
        }
        m_Material.SetFloat("DrawRange", m_drawRange);
    }

    // Update is called once per frame
    void Update()
    {
        // �v���C���[���W�̎Q��
        m_Material.SetVector("_PlayerPosition", m_PlayeObject.transform.position);
        // �`��͈͂̐ݒ�
        m_Material.SetFloat("_DrawRange", m_drawRange);
    }
}
