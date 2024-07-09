using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FenceStyle : MonoBehaviour
{
    //[Header("�B�̖{���i�����ݒ�j"), SerializeField]
    //private int numFence = 0; // �B�̐�

    [Header("�B�I�u�W�F�N�g�i�v���n�u�p�j"), SerializeField]
    private GameObject prefabFence = null;

    [Header("�B�̊Ԋu"), Range(0.0f, 1.0f), SerializeField]
    private float startWidth = 1.0f;

    [Header("�I�u�W�F�N�g�m�F�p"), SerializeField]
    private List<GameObject> fences = new List<GameObject>(); // �X�̟B�I�u�W�F�N�g�i�[

    void Awake()
    {
        Destroy(this.gameObject.transform.GetComponent<MeshFilter>());
        Destroy(this.gameObject.transform.GetComponent<MeshRenderer>());

        if(prefabFence == null)
        {
            Debug.LogError("�v���n�u�������B�I�u�W�F�N�g�����݂��܂���");
            return;
        }

        // �B�̌��_�p�I�u�W�F�N�g���擾
        GameObject centerObj = this.transform.GetChild(0).transform.gameObject;
        if(centerObj == null)
        {
            Debug.LogError("���S�p�q�I�u�W�F�N�g�����݂��܂���");
            return;
        }


        // �O���[�o�����W�̌��_�ɂ���
        centerObj.transform.parent = null; // ��U�A�e�q�֌W��؂�
        centerObj.transform.position = Vector3.zero;
        centerObj.transform.rotation = Quaternion.identity;


        // X����Scale�şB�̖{�����w��i�l�̌ܓ��j
        int numFence = Mathf.Abs(Mathf.RoundToInt(this.transform.localScale.x));


        GameObject obj = null; // �ǉ��I�u�W�F�N�g�ێ��p
        float width = startWidth;
        float saveWidth = 0.0f; // �Ԋu�̒l�̕ێ��p


        // �B�̖{������Ȃ�
        // ���S�ɟB�I�u�W�F�N�g�𐶐�
        if (numFence % 2 == 1)
        {
            obj = Instantiate(prefabFence, Vector3.zero, Quaternion.identity);
            obj.transform.position = Vector3.zero;
            obj.transform.parent = centerObj.transform;
            fences.Add(obj);
        }
        else
        {
            width /= 2.0f;
            saveWidth = width;
        }


        // �Ԋu���Y�����Ȃ���{�����A
        // �B�I�u�W�F�N�g�𐶐�
        for (int i = 0; i < numFence / 2; i++)
        {
            obj = Instantiate(prefabFence, Vector3.zero, Quaternion.identity);
            obj.transform.position = Vector3.right * (width * (i + 1) + saveWidth * i);
            obj.transform.parent = centerObj.transform;
            fences.Add(obj);
            obj = Instantiate(prefabFence, Vector3.zero, Quaternion.identity);
            obj.transform.position = -Vector3.right * (width * (i + 1) + saveWidth * i);
            obj.transform.parent = centerObj.transform;
            fences.Add(obj);
        }

        // �B�̌��_�����̍��W�ɖ߂�
        centerObj.transform.rotation = this.transform.rotation;
        centerObj.transform.parent = this.transform; // �e�q�֌W�𕜌�
        centerObj.transform.localPosition = Vector3.zero;
    }
}
