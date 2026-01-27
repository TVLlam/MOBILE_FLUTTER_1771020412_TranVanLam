using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using PickleballAPI.Models;

namespace PickleballAPI.Data;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }
    
    public DbSet<Member> Members { get; set; }
    public DbSet<Court> Courts { get; set; }
    public DbSet<Booking> Bookings { get; set; }
    public DbSet<WalletTransaction> WalletTransactions { get; set; }
    public DbSet<Tournament> Tournaments { get; set; }
    public DbSet<TournamentRegistration> TournamentRegistrations { get; set; }
    public DbSet<Match> Matches { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Member configuration
        modelBuilder.Entity<Member>()
            .HasOne(m => m.User)
            .WithOne(u => u.Member)
            .HasForeignKey<Member>(m => m.UserId)
            .OnDelete(DeleteBehavior.Cascade);
        
        // Booking configuration
        modelBuilder.Entity<Booking>()
            .HasOne(b => b.Member)
            .WithMany(m => m.Bookings)
            .HasForeignKey(b => b.MemberId)
            .OnDelete(DeleteBehavior.Restrict);
        
        modelBuilder.Entity<Booking>()
            .HasOne(b => b.Court)
            .WithMany(c => c.Bookings)
            .HasForeignKey(b => b.CourtId)
            .OnDelete(DeleteBehavior.Restrict);
        
        // WalletTransaction configuration
        modelBuilder.Entity<WalletTransaction>()
            .HasOne(wt => wt.Member)
            .WithMany(m => m.WalletTransactions)
            .HasForeignKey(wt => wt.MemberId)
            .OnDelete(DeleteBehavior.Restrict);
        
        // Tournament configuration
        modelBuilder.Entity<Tournament>()
            .HasMany(t => t.Registrations)
            .WithOne(tr => tr.Tournament)
            .HasForeignKey(tr => tr.TournamentId)
            .OnDelete(DeleteBehavior.Cascade);
        
        modelBuilder.Entity<Tournament>()
            .HasMany(t => t.Matches)
            .WithOne(m => m.Tournament)
            .HasForeignKey(m => m.TournamentId)
            .OnDelete(DeleteBehavior.Cascade);
        
        // TournamentRegistration configuration
        modelBuilder.Entity<TournamentRegistration>()
            .HasOne(tr => tr.Member)
            .WithMany(m => m.TournamentRegistrations)
            .HasForeignKey(tr => tr.MemberId)
            .OnDelete(DeleteBehavior.Restrict);
        
        // Match configuration
        modelBuilder.Entity<Match>()
            .HasOne(m => m.Court)
            .WithMany()
            .HasForeignKey(m => m.CourtId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
