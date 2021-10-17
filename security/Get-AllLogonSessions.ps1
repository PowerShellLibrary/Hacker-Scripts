<#
    .DESCRIPTION
    Retrieves every current logon session on the computer,
    including services or network access such as SMB, ssh, RDP etc.

    .NOTES
    If you get lots of 0xC0000022 errors (which mean ACCESS_DENIED)
    that's because you're not running as an administrator and therefore
    do not have permission to get information about these sessions.
#>

[CmdletBinding()]

$TypeDefinition = @'
  using System;
  namespace LogonNameSpace {
      using System;
      using System.Runtime.InteropServices;

      public enum SECURITY_LOGON_TYPE : uint {
        SYSTEM = 0,
        UNKNOWN = 1,
        Interactive = 2,         // The security principal is logging on interactively.
        Network,                 // The security principal is logging using a network.
        Batch,                   // The logon is for a batch process.
        Service,                 // The logon is for a service account.
        Proxy,                   // Not supported.
        Unlock,                  // The logon is an attempt to unlock a workstation.
        NetworkCleartext,        // The logon is a network logon with cleartext credentials.
        NewCredentials,          // Allows the caller to clone its current token and specify new credentials for outbound connections.
        RemoteInteractive,       // A terminal server session that is both remote and interactive.
        CachedInteractive,       // Attempt to use the cached credentials without going out across the network.
        CachedRemoteInteractive, // Same as RemoteInteractive, except used internally for auditing purposes.
        CachedUnlock             // The logon is an attempt to unlock a workstation.
      }

      [StructLayout(LayoutKind.Sequential)]
      public struct LSA_UNICODE_STRING {
        public UInt16 Length;
        public UInt16 MaximumLength;
        public IntPtr buffer;
      }

      [StructLayout(LayoutKind.Sequential)]
      public struct LUID {
        public UInt32 LowPart;
        public Int32 HighPart;
      }

      [StructLayout(LayoutKind.Sequential)]
        public struct SECURITY_LOGON_SESSION_DATA {
        public UInt32 Size;
        public LUID LoginID;
        public LSA_UNICODE_STRING Username;
        public LSA_UNICODE_STRING LoginDomain;
        public LSA_UNICODE_STRING AuthenticationPackage;
        public UInt32 LogonType;
        public UInt32 Session;
        public IntPtr PSiD;
        public UInt64 LoginTime;
        public LSA_UNICODE_STRING LogonServer;
        public LSA_UNICODE_STRING DnsDomainName;
        public LSA_UNICODE_STRING Upn;
      }

      public sealed class LogonClass {
      [DllImport("secur32.dll", SetLastError = false)]
      public static extern uint LsaFreeReturnBuffer(IntPtr buffer);

      [DllImport("Secur32.dll", SetLastError = false)]
      public static extern uint LsaEnumerateLogonSessions(out UInt64 LogonSessionCount, out IntPtr LogonSessionList);

      [DllImport("Secur32.dll", SetLastError = false)]
      public static extern uint LsaGetLogonSessionData(IntPtr luid, out IntPtr ppLogonSessionData);
      }
  }
'@

if (-not ('LogonNameSpace.LogonClass' -as [type])) {
    $null = Add-Type -TypeDefinition $TypeDefinition -Language CSharp
}

$count = [System.UInt64]0
$luidPtr = [System.IntPtr]::Zero

# Gets an array of pointers to LUIDs
$null = [LogonNameSpace.LogonClass]::LsaEnumerateLogonSessions([ref]$count, [ref]$luidPtr)

# Set the pointer to the start of the array
$iter = $luidPtr
Write-Verbose "$count sessions in total."

for ($i = 0; $i -lt $count; $i++) {
    $data = $null
    $sessionData = [System.IntPtr]::new(0)
    $SessionLUID = [System.Runtime.InteropServices.Marshal]::PtrToStructure($iter, [System.Type][LogonNameSpace.LUID])

    $LsaGetLogonSessionDataReturn = [LogonNameSpace.LogonClass]::LsaGetLogonSessionData($iter, [ref]$sessionData)
    if ($LsaGetLogonSessionDataReturn -ne 0) {
        Write-Error ("Could not get information for session $($SessionLUID.HighPart):$($SessionLUID.LowPart). LsaGetLogonSessionData returned: $LsaGetLogonSessionDataReturn (0x{0:X8})" -f $LsaGetLogonSessionDataReturn)
    } else {
        $data = [System.Runtime.InteropServices.Marshal]::PtrToStructure($sessionData,[System.Type][LogonNameSpace.SECURITY_LOGON_SESSION_DATA])

        # if we have a valid logon
        if (($null -ne $data) -and ($data.PSiD -ne [System.IntPtr]::Zero)) {
            $LOGONTYPE = New-Object LogonNameSpace.SECURITY_LOGON_TYPE
            $LOGONTYPE.value__ = $data.LogonType
            [PSCustomObject]@{
                SessionLUID    = "$($SessionLUID.HighPart):$($SessionLUID.LowPart)"
                Domain         = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($data.LoginDomain.buffer).Trim()
                UserName       = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($data.Username.buffer).Trim()
                SID            = [System.Security.Principal.SecurityIdentifier]::new($data.PSiD)
                Account        = [System.Security.Principal.SecurityIdentifier]::new($data.PSiD).Translate([system.security.principal.ntaccount]).Value
                SessionID      = $data.Session
                LogonType      = $LOGONTYPE
                Authentication = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($data.AuthenticationPackage.buffer).Trim()
                DnsDomainName  = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($data.DnsDomainName.buffer).Trim()
                LogonServer    = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($data.LogonServer.buffer).Trim()
                Upn            = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($data.Upn.buffer).Trim()
                LogonTime      = [System.DateTime]::new($data.LoginTime)
            }
        } else {
            Write-Warning "Invalid data for session LUID $($SessionLUID.HighPart):$($SessionLUID.LowPart)"
        }
    }

    # move the pointer forward
    $iter=[System.IntPtr]::Add($iter,[System.Runtime.InteropServices.Marshal]::SizeOf([System.Type][LogonNameSpace.LUID]))

    # free the SECURITY_LOGON_SESSION_DATA memory in the struct
    $null = [LogonNameSpace.LogonClass]::LsaFreeReturnBuffer($sessionData)
}
# free the array of LUIDs
$null = [LogonNameSpace.LogonClass]::LsaFreeReturnBuffer($luidPtr)

