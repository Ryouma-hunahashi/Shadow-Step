using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WayPoint_Setting : MonoBehaviour
{
    [SerializeField, Tooltip("��~����")]
    private float m_StopTime;

    public float GetStopTime() { return m_StopTime; }
}
