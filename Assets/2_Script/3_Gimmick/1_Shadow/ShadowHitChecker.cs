using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowHitChecker : MonoBehaviour
{
    // �������Ă���e�̃I�u�W�F���X�g
    private List<Transform> hitShadowTransforms = new List<Transform>();
    // �������Ă���e�̃}�l�[�W���[�I�u�W�F�N�g
    private List<Transform> hitManagerTransforms = new List<Transform>();



    /// <summary>
    /// �����̃}�l�[�W���[�I�u�W�F�N�g�����̃|�C���g�ɓ������Ă��邩���m�F
    /// </summary>
    /// <param name="trans">�}�l�[�W���[�̃g�����X�t�H�[��</param>
    /// <returns></returns>
    public bool CheckHitTrans(Transform trans)
    {
        for(int i = 0; i < hitManagerTransforms.Count; i++)
        {
            if(hitManagerTransforms[i] == trans)
            {
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// �����̉e�I�u�W�F�N�g�����̃|�C���g�ɓ������Ă��邩���m�F
    /// </summary>
    /// <param name="trans">�e�̃g�����X�t�H�[��</param>
    /// <returns></returns>
    public bool CheckHitShadow(Transform trans)
    {
        for (int i = 0; i < hitShadowTransforms.Count; i++)
        {
            if (hitShadowTransforms[i] == trans)
            {
                return true;
            }
        }
        return false;
    }

    public int CountHit() { return hitManagerTransforms.Count; }

    public Transform[] GetAllHitShadows() { return hitShadowTransforms.ToArray(); }
    public Transform[] GetAllHitManagers() { return hitManagerTransforms.ToArray(); }

    private void LateUpdate()
    {
        // �Ƃ肠���������O�Ƀ}�l�[�W���[�̓��Z�b�g
        hitManagerTransforms.Clear();
        // �q�b�g���Ă���e�̕��J��Ԃ�
        for (int i = hitShadowTransforms.Count - 1; i >= 0; i--)
        {
            // �����A�g���Ă��Ȃ��e������Δr������
            if (hitShadowTransforms[i].parent.parent == null)
            {
                hitShadowTransforms[i] = hitShadowTransforms[hitShadowTransforms.Count - 1];
                hitShadowTransforms.RemoveAt(hitShadowTransforms.Count - 1);
            }
        }

        // ���̎��_�œo�^����Ă��Ȃ���Δ�����
        if (hitShadowTransforms.Count == 0) { return; }

        // ��ڂ͔��悤���Ȃ��̂œo�^
        hitManagerTransforms.Add(hitShadowTransforms[0].parent.parent);
        // �������Ă���e���J��Ԃ�
        for (int j = 1; j < hitShadowTransforms.Count; j++)
        {
            // �o�^�\�����`�F�b�N
            bool search = true;
            for (int i = 0; i < hitManagerTransforms.Count; i++)
            {
                // �����}�l�[�W���[������Γo�^����
                if (hitShadowTransforms[j].parent.parent == hitManagerTransforms[i])
                {
                    search = false;
                    break;
                }
            }
            if (search)
            {
                hitManagerTransforms.Add(hitShadowTransforms[j].parent.parent);
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        // �������Ă���̂��e�łȂ���Ώ������I����
        if (!other.gameObject.CompareTag("Shadow")) { return; }
        // �e�̐e���擾
        // ���������g�����X�t�H�[�����擾
        Transform otherTrans = other.transform;
        // �e�̐e�����Ȃ���Ώ������I����
        if (otherTrans.parent.parent == null) { return; }

        // �o�^�\�����`�F�b�N
        bool search = true;
        for (int i = 0; i < hitShadowTransforms.Count; i++)
        {
            // �����e������Γo�^����
            if (hitShadowTransforms[i] == otherTrans)
            {
                search = false;
                break;
            }
        }
        if(search)
        {
            hitShadowTransforms.Add(otherTrans);
        }

    }

    private void OnTriggerExit(Collider other)
    {
        // �e�łȂ���Ώ������I����
        if (!other.gameObject.CompareTag("Shadow")) { return; }

        // �e�̃g�����X�t�H�[�����擾
        Transform otherTrans = other.transform;
        for (int i = 0; i < hitShadowTransforms.Count; i++)
        {
            // �������̂�����΃q�b�g��������O��
            if (hitShadowTransforms[i] == otherTrans)
            {
                hitShadowTransforms[i] = hitShadowTransforms[hitShadowTransforms.Count - 1];
                hitShadowTransforms.RemoveAt(hitShadowTransforms.Count - 1);
                break;
            }
        }
    }
}
